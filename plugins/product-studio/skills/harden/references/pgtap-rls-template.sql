-- supabase/tests/10-rls-<table>.sql
-- RLS proof for one tenant-owned table. Requires 00000-supabase_test_helpers.sql (basejump helpers).
-- Replace <table>, <tenant_col>, and the insert columns. One file per table group.
begin;
select plan(8);

-- RLS is enabled on this table (the schema-wide form also counts views, so check per table)
select tests.rls_enabled('public', '<table>');

-- two users in two different organisations
select tests.create_supabase_user('owner_a');
select tests.create_supabase_user('user_b');
-- create orgs + memberships the way the app does (adapt to your schema)
-- insert into organisations (id, name) values ('00000000-0000-0000-0000-00000000000a','A'), ('00000000-0000-0000-0000-00000000000b','B');
-- insert into memberships (user_id, organisation_id, role) values (tests.get_supabase_uid('owner_a'), '...0a', 'owner'), (tests.get_supabase_uid('user_b'), '...0b', 'owner');

-- owner A creates a row
select tests.authenticate_as('owner_a');
select lives_ok(
  $$ insert into public.<table> (<tenant_col>, name) values ('00000000-0000-0000-0000-00000000000a', 'row of A') $$,
  'owner A can insert into own organisation'
);
select results_eq(
  $$ select count(*)::int from public.<table> where name = 'row of A' $$,
  array[1], 'owner A can read own row'
);

-- user B cannot see, change or delete it
select tests.authenticate_as('user_b');
select is_empty($$ select * from public.<table> where name = 'row of A' $$, 'user B cannot read A''s row');
select results_eq(
  $$ with u as (update public.<table> set name = 'hacked' where name = 'row of A' returning 1) select count(*)::int from u $$,
  array[0], 'user B cannot update A''s row'
);
select results_eq(
  $$ with d as (delete from public.<table> where name = 'row of A' returning 1) select count(*)::int from d $$,
  array[0], 'user B cannot delete A''s row'
);
select throws_ok(
  $$ insert into public.<table> (<tenant_col>, name) values ('00000000-0000-0000-0000-00000000000a', 'planted by B') $$,
  '42501', null, 'user B cannot insert into A''s organisation (RLS violation, not some other error)'
);

-- anonymous visitors see nothing
select tests.clear_authentication();
select is_empty($$ select * from public.<table> $$, 'anon cannot read');

select * from finish();
rollback;
