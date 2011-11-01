# -*- coding: utf-8 -*-
#
#  SQLiteConnectionExtend.rb
#  SQLite3
#
#  Created by Hiroyuki Takahashi on 11/10/31.
#  Copyright 2011年 __MyCompanyName__. All rights reserved.
#

class SQLite3Connection
  def prepare
    p 'huga'
  end

  def close
    return SQLite3ConnectionClose(connection)
  end

  def query sql, bindings=nil, &p
    stmt = statementWithQuery sql
    stmt.bindWithDictionary bindings if bindings
    if p
      while SQLITE_ROW == stmt.step
        row = []
        stmt.columnCount.times do |i|
          row.push stmt.objectWithColumn(i)
        end
        p.call row
      end
      stmt.reset
    end
    stmt
  end

  def get_first_value sql, bindings=nil
    value = nil
    stmt = query sql, bindings
    if SQLITE_ROW == stmt.step
      value = stmt.objectWithColumn(0)
      stmt.reset
    end
    value
  end

  def column sql, n=0, bindings=nil
    value = nil
    stmt = query sql, bindings
    if SQLITE_ROW == stmt.step
      value = stmt.objectWithColumn(n)
      stmt.reset
    end
    value
  end

  def column_with_name sql, name, bindings=nil
    value = nil
    stmt = query sql, bindings
    if SQLITE_ROW == stmt.step
      value = stmt.objectWithColumnName(name)
      stmt.reset
    end
    value
  end

  def create_function name, &p
    createFunction name, dataType:-1, usingBlock:Proc.new {|args|
      p.call(*args)
    }
  end
end
