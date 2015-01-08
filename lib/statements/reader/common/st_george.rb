module StGeorge
  ABNS = %w[33007457141 92055513070]

  def st_george?
    document =~ /\bSt\. *George\b/ && document =~ /\bABN *((?:\d *){11})/ && ABNS.include?($1.delete ' ')
  end

  def years
    @years ||= period.map(&:year)
  end

  def parse_date(str)
    date = change_year(Time.parse(str.to_s.strip), years.first)
    date = change_year(date, years.last) if date < period.first
    date
  end

  def period
    @period ||= (pages.first =~ %r`Statement Period\s+(\d\d/\d\d/\d{4})\s+to\s+(\d\d/\d\d/\d{4})` && [Time.parse($1), Time.parse($2)])
  end

  def account_number
    @account_number ||= document[/Account Number ([\d ]+)/, 1].strip.gsub(/\s+/, ' ')
  end

  private

  def change_year(time, year)
    Time.new year, time.month, time.day
  end
end
