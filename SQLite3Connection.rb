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

    if bindings
      if bindings.is_a? Hash
        stmt.bindWithDictionary bindings
      elsif bindings.is_a? Array
        stmt.bindWithArray bindings
      else
        stmt.bindObject bindings, withIndex:1
      end
    end

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

  def column sql, bindings=nil, n=0
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

  def row sql, bindings=nil, n=0
    stmt = query sql, bindings

   (n+1).times { stmt.step }

    return [].instance_eval do
      stmt.columnCount.times do |i|
        self.push stmt.objectWithColumn(i)
      end
      self
    end
  end

  def create_function name, &p
    createFunction name, dataType:-1, usingBlock:Proc.new {|args|
      p.call(*args)
    }
  end
end
