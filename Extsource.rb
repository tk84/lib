# -*- coding: utf-8 -*-

module Tk84
  class Extsource

    def initialize
      @source = {}
      @parser = {}
      @parsed = {}
    end

    def method_missing type, *args

      # 関数名に _ （アンダースコア）が含まれている場合の処理
      args = [].instance_eval do
        type.scan /(^[^_]+(?=_))|[_]+([^_]+)/ do |s|
          if Regexp.last_match 1
            type = Regexp.last_match(1).to_sym
          else
            self.push Regexp.last_match(2).to_sym
          end
        end
        self
      end + args

      # パーサが登録されているメソッドのみ許可
      raise NoMethodError, "unkonwn method `#{type}:': " if
        not @parser[type] or not @parser[type].is_a? Class
      id = args.shift

      if not @parsed[type][id]
        parser = @parser[type].new
        raise NoMethodError, "The Class `#{type}:' doesn't have parse method." if
          not parser.respond_to? :parse
        parser.parse(@source[type][id])
        @parsed[type][id] = parser
      elsif
        parser = @parsed[type][id]
      end

      parser.result(*args)
    end

    def parser type, parser
      @parser.store type.to_sym, parser
      @parsed[type] = {} if not @parsed[type]
    end

    def source type, *args
      (args[0].kind_of?(Hash) ? args[0] : Hash[*args]).each_pair do |key, value|
        @parsed[type][key] = nil if @parsed[type] && @parsed[type][key]
        @source[type] = {} if not @source[type]
        @source[type][key] = value
      end
    end

    def debug
      p @source
      p @parser
      p @parsed
    end
  end

  module Parser
    class Srt
      require 'nkf'

      def initialize
        @result = nil
      end

      def parse file
        status = false
        file = file.path if file.respond_to? :path

        if FileTest.file? file and FileTest.readable? file
          File.open file, 'r' do |file|
            records = []
            section = ''

            file.each_line do |line|
              line = NKF.nkf('--utf8', line)

              # ファイル終端の処理
              if file.eof?
                section << line
                line = "\n"
              end

              if line =~ /^(\r\n|\n)/ then
                if section =~ /(?:^|\r?\n)(\d+)\r?\n(\d{2}):(\d{2}):(\d{2}),(\d{3}) --> (\d{2}):(\d{2}):(\d{2}),(\d{3})\r?\n(.*)/m then
                  records << {
                    seq:Regexp.last_match(1).to_i,
                    btime:((Regexp.last_match(2).to_f * 60 * 60) +
                      (Regexp.last_match(3).to_f * 60) +
                      (Regexp.last_match(4).to_f * 1) +
                      (Regexp.last_match(5).to_f / 1000)),
                    etime:((Regexp.last_match(6).to_f * 60 * 60) +
                      (Regexp.last_match(7).to_f * 60) +
                      (Regexp.last_match(8).to_f * 1) +
                      (Regexp.last_match(9).to_f / 1000)),
                    caption:Regexp.last_match(10).chomp
                  }
                end
                section = ''
              else
                section << line
              end
            end

            if records.count
              status = true
              @result = records
            end
          end
        end

        status
      end

      def result
        @result
      end
    end

    class Sql
      def initialize
        @result = {}
      end

      def parse source
        res = nil
        File.open(source, 'r') do |file|
          contents = file.read
          contents.scan /(?=^|\n)--:([\w]+)((?:(?!\n--:[\w+])\n[^\n]*)*)/ do |s|
            id = Regexp.last_match(1).to_sym
            @result.store id, Regexp.last_match(0)
          end
        end
      end

      def result id, placeholder={}
        result = @result[id].dup

        placeholder.each_pair do |key,value|
          result.gsub! "\#{#{key}}", value
        end

        result
      end
    end
  end
end
