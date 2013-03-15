drop table transaction_entries;
drop table inventory_transactions;
drop table inventory_items;
drop table accounts;
drop table employees;


create table employees(
  id serial primary key,
  first_name varchar(30) not null,
  last_name  varchar(30) not null,
  occupation varchar(50),
  is_active boolean not null default true
);

create table accounts (
  id serial primary key,
  number varchar(30) not null,
  type varchar(50) not null
);

create table inventory_items (
  id serial primary key,
  name varchar(200) not null,
  code varchar(10) not null,
  measurement_unit varchar(30) not null,
  unit_price numeric(8,2) not null
);

create table inventory_transactions (
  id serial primary key,
  transaction_date date not null,
  type varchar(50) not null
);

create table transaction_entries (
  id serial primary key,
  type varchar(50) not null,
  inventory_transaction_id integer not null references inventory_transactions(id),
  inventory_item_id integer not null references inventory_items(id),
  account_id integer not null references accounts(id),
  employee_id integer not null references employees(id),
  inventory_amount numeric(8,2) not null
);
