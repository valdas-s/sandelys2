#!/usr/bin/ruby

#
# Old structure
#
#CREATE TABLE EMPLOYEES(EMPLOYEE_ID BIGINT,
#                       FIRSTNAME VARCHAR(255),
#                       LASTNAME VARCHAR(255),
#                       IS_ACTIVE BOOLEAN,
#                       OCCUPATION VARCHAR(255))
#CREATE TABLE INVENTORY(ITEM_ID BIGINT,
#                       DESCRIPTION VARCHAR(255),
#                       COST DOUBLE,
#                       UNIT VARCHAR(255),
#                       EXTERNAL_CODE VARCHAR(255),
#                       ACCOUNT_NUMBER VARCHAR(255))
#CREATE TABLE TRANSACTIONS(TRANSACTION_ID BIGINT ,
#                          TRANSACTION_TYPE VARCHAR(255),
#                          AMOUNT DOUBLE,
#                          TRANSACTION_DATE TIMESTAMP,
#                          TO_PERSON_ID BIGINT,
#                          FROM_PERSON_ID BIGINT,
#                          ITEM_ID BIGINT,
#                          SEQUENCE INTEGER)

require "English"
require "date"

DBEmployee = Struct.new("DBEmployee", :id, :fname, :lname, :active, :occupation)
DBInventoryItem = Struct.new("DBInventoryItem", :id, :name, :cost, :unit, :code, :account_number)
DBTransaction = Struct.new("DBTransaction", :id, :type, :amount, :date, :to_employee_id, :from_employee_id, :item_id, :sequence)

Account = Struct.new("Account", :id, :number)
Transaction = Struct.new("Transaction", :id, :date, :type, :entries)
TransactionEntry = Struct.new("TransactionEntry", :id, :type, :item_id, :employee_id, :account_id, :amount)

class DataConverter

  def initialize()
  end

  def convertFile(fileName)
    @db_items={}
    @db_employees={}
    @db_transactions={}

    @accounts = {}
    @transactions = {}
    @transaction_id = @account_id = @entry_id = 1

    read_input_from(fileName)
    process_data
    create_setup_script
  end

  private
  def read_input_from(fileName)
    dbFile = File.new(fileName)

    dbFile.each_line do |line|
      case line
        when /INSERT INTO EMPLOYEES VALUES\((.*)\)/
          collect_employee_info($1)
        when /INSERT INTO INVENTORY VALUES\((.*)\)/
          collect_inventory_info($1)
        when /INSERT INTO TRANSACTIONS VALUES\((.*)\)/
          collect_transaction_info($1)
      end
    end

    dbFile.close
  end

  def process_data
    # Extract accounts and create transactions + transaction entries

    @db_items.values.each do |i|
      account = find_account_by_number(i.account_number)
      if account == nil
        account = Account.new(@account_id, i.account_number)
        @accounts[account.id] = account
        @account_id += 1
      end

      transactions_for_item(i).each do |t|
        case t.type
          when 1 # Add inventory
            trans=Transaction.new(@transaction_id,t.date,'InventoryAddTransaction', [])
            trans.entries << TransactionEntry.new(@entry_id,'AssignEntry', t.item_id, t.to_employee_id, account.id, t.amount)
            @transaction_id += 1
            @entry_id += 1
            @transactions[trans.id] = trans
          when 2 # Remove inventory
            trans=Transaction.new(@transaction_id,t.date,'InventoryRemoveTransaction', [])
            trans.entries << TransactionEntry.new(@entry_id,'RemoveEntry', t.item_id, t.from_employee_id, account.id, -t.amount)
            @transaction_id += 1
            @entry_id += 1
            @transactions[trans.id] = trans
          when 3 # Remove inventory
            trans=Transaction.new(@transaction_id,t.date,'InventoryTransferTransaction', [])
            trans.entries << TransactionEntry.new(@entry_id,'AssignEntry', t.item_id, t.to_employee_id, account.id, t.amount)
            trans.entries << TransactionEntry.new(@entry_id+1,'RemoveEntry', t.item_id, t.from_employee_id, account.id, -t.amount)
            @transaction_id += 1
            @entry_id += 2
            @transactions[trans.id] = trans
        end
      end
    end
  end

  def create_setup_script
    # Populate employees
    @db_employees.values.each do |e|
      puts "insert into employees(id,first_name,last_name,occupation,is_active) values(#{e.id},'#{e.fname}','#{e.lname}','#{e.occupation}',#{e.active});"
    end

    # Populate accounts
    @accounts.values.each do |a|
      puts "insert into accounts(id,number,type) values(#{a.id},'#{a.number}','RegularAccount');"
    end

    @db_items.values.each do |i|
      puts "insert into inventory_items(id,name,code,measurement_unit,unit_price) values(#{i.id},'#{i.name}','#{i.code}','#{i.unit}',#{i.cost});"
    end

    @transactions.values.each do |t|
      puts "insert into inventory_transactions(id,transaction_date,type) values(#{t.id},date '#{t.date.to_s}','#{t.type}');"
      t.entries.each do |e|
        puts "insert into transaction_entries(id,type,inventory_transaction_id,inventory_item_id,account_id,employee_id,inventory_amount) values(#{e.id},'#{e.type}',#{t.id},#{e.item_id},#{e.account_id},#{e.employee_id},#{e.amount});"
      end
    end

    # Reset sequence numbers for all tables
    max_emp_id = @db_employees.keys.collect{ |k| k.to_i}.max
    max_item_id = @db_items.keys.collect{ |k| k.to_i}.max
    puts "SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('employees', 'id'), #{max_emp_id}, true);"
    puts "SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('accounts', 'id'), #{@account_id-1}, true);"
    puts "SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('inventory_items', 'id'), #{max_item_id}, true);"
    puts "SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('inventory_transactions', 'id'), #{@transaction_id-1}, true);"
    puts "SELECT pg_catalog.setval(pg_catalog.pg_get_serial_sequence('transaction_entries', 'id'), #{@entry_id-1}, true);"
  end

  def collect_employee_info(values)
    values =~ /(\d+),'(.*?)','(.*?)',(\w+),'(.*?)'/
    e = DBEmployee.new($1.to_i, $2, $3, $4, $5)
    @db_employees[e.id] = e
#    puts "id: #{e.id}, o: #{e.occupation}"
  end

  def collect_inventory_info(values)
    values =~ /(\d+),'(.*?)',(\d+\.\d+)E0,'(.*?)','(.*?)','(.*?)'/
     i = DBInventoryItem.new($1.to_i, $2, $3.to_f, $4, $5, $6)
    @db_items[i.id] = i
#    puts "id: #{i.id}, o: #{i.cost}"
    raise "Item id is out of sequence: "+ i.id if @db_items.length != i.id
  end

  def collect_transaction_info(values)
    values =~ /(\d+),'(\d+)',(\d+\.\d+)E0,'(\d{4}-\d{2}-\d{2}) 00:00:00.0',(\w+),(\w+),(\d+),(\d+)/
    id, type, amount, date, to_emp_id, from_emp_id, item_id, seq = $1.to_i, $2.to_i, $3.to_f, $4, $5, $6, $7.to_i, $8.to_i
    date_parts = date.split('-')
    t = DBTransaction.new(id, type, amount, Date.new(date_parts[0].to_i, date_parts[1].to_i, date_parts[2].to_i), to_emp_id, from_emp_id, item_id, seq)
    @db_transactions[t.id] = t
#    puts "id: #{t.id}, o: #{t.date} #{t.item_id} [#{t.sequence}]"
  end

  def find_account_by_number(account_number)
    @accounts.values.each do |acct|
      return acct if account_number == acct.number
    end
    return nil
  end

  def transactions_for_item(item)
    transactions = []
    @db_transactions.values.each {|t| transactions << t if t.item_id == item.id}
    return transactions.sort {|a,b| a.sequence <=> b.sequence}
  end
end


if ARGV.length == 0
  puts "Usage: #{$PROGRAM_NAME} <dbfile.script>"
  exit
end

converter = DataConverter.new
converter.convertFile(ARGV[0])
