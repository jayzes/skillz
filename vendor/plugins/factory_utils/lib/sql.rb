module Sql
  
  def self.MySQL?
    ActiveRecord::Base.connection.adapter_name == 'MySQL'
  end
  
  def self.concat(*args)
    MySQL? ? "CONCAT(#{args.join(', ')})" : args.join(' || ')
  end

  def self.lowercase(expr)
    MySQL? ? "LCASE(#{expr})" : "LOWER(#{expr})"
  end

  def self.year(expr, type='INTEGER')
    MySQL? ? "YEAR(#{expr})" : "CAST(STRFTIME('%Y', #{expr}) as '#{type}')"
  end

  def self.month(expr, type='INTEGER')
    MySQL? ? "MONTH(#{expr})" : "CAST(STRFTIME('%m', #{expr}) as '#{type}')"
  end

  def self.day(expr, type='INTEGER')
    MySQL? ? "DAY(#{expr})" : "CAST(STRFTIME('%d', #{expr}) as '#{type}')"
  end
  
  def self.strftime(format, expr)
    # figure out format parsing for year month day
    raise "not implemented"
    MySQL? ? "DAY(#{expr})" : "STRFTIME('#{format}', #{expr})"
  end

  def self.now
    MySQL? ? "NOW()" : "CURRENT_TIMESTAMP"
  end
  
  def self.bool(value)
    MySQL? ? ( value ? 1 : 0 ) : ( value ? "'t'" : "'f'" )
  end

  def self.random
    MySQL? ? "RAND()" : "RANDOM()"
  end
  
end