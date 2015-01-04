module StGeorge
  def st_george?
    include?('St.George Bank') && (include?('ABN 33 007 457 141') || include?('ABN 92 055 513 070'))
  end
end
