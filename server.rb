require 'mysql2'
require 'sinatra'

@@mysqlclient = Mysql2::Client.new(:host => "192.168.139.129", :username => "root", :database => "time_collect")

get '/' do
  "Hello world, it's #{Time.now} at the server!"
end

get '/report' do
  res = Array.new

  kst = "6553, 6555, 6557, 6558, 6562, 6560, 6563, 6564, 6565, 6566"
  first_of_month = "20130301"

  query = %Q{ select cc.CostCentreID Kostenstelle, cc.description Beschreibung, 
                     sum(jt.Costs) 'aufgelaufene Kosten', 'Feb 2013' bis
              from costcentre cc, jobtime jt
              where cc.PrimaryKey = jt.FK_CostCentre
                and cc.CostCentreID in (#{kst})
                and jt.Date < '#{first_of_month}'
              group by cc.CostCentreID, cc.description, 'Feb 2013' }

  result = @@mysqlclient.query(query, :as => :array)
  result.each do | row |
    res.push(row)
  end
  return res.to_s
end
