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
end
