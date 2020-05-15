-- Start transaction and plan tests
begin;
select plan(2);

-- Declare some variables
\set user1ID '00000000-0000-0000-0000-000000000001'
\set package1ID '00000000-0000-0000-0000-000000000001'
\set event1ID '00000000-0000-0000-0000-000000000001'
\set notification1ID '00000000-0000-0000-0000-000000000001'

-- No pending events available yet
select is_empty(
    $$ select get_pending_notification()::jsonb $$,
    'Should not return a notification'
);

-- Seed some data
insert into "user" (user_id, alias, email) values (:'user1ID', 'user1', 'user1@email.com');
insert into package (
    package_id,
    name,
    latest_version,
    package_kind_id
) values (
    :'package1ID',
    'Package 1',
    '1.0.0',
    1
);
insert into event (event_id, package_version, package_id, event_kind_id)
values (:'event1ID', '1.0.0', :'package1ID', 0);
insert into notification (notification_id, event_id, user_id)
values (:'notification1ID', :'event1ID', :'user1ID');

-- Run some tests
select is(
    get_pending_notification()::jsonb,
    '{
        "notification_id": "00000000-0000-0000-0000-000000000001",
        "event": {
            "event_id": "00000000-0000-0000-0000-000000000001",
            "event_kind": 0,
            "package_id": "00000000-0000-0000-0000-000000000001",
            "package_version": "1.0.0"
        },
        "user": {
            "email": "user1@email.com"
        }
	}'::jsonb,
    'A notification should be returned'
);

-- Finish tests and rollback transaction
select * from finish();
rollback;