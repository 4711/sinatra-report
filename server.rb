require 'mysql2'
require 'active_record'
require 'sinatra'
require 'csv'
require 'json'
require 'xmlsimple'
require 'sinatra/respond_to'

Sinatra::Application.register Sinatra::RespondTo

get '/' do
    "Hello world, it's #{Time.now} at the server!"
end

get '/report' do
    format_response MyAPI.get_report()
end

def format_response(data)
    respond_to do |format|
        format.html { data.to_s }
        format.txt  { data.to_s }
        format.csv  { data.to_csv }
        format.xml  { data.to_xml }
        format.json { data.to_json }
    end
end

class MyAPI < ActiveRecord::Base
    class << self

        dbconfig = {
            :adapter  => "mysql2",
            :host     => "192.168.139.129",
            :username => "root",
            :password => "",
            :database => "time_collect"
        }

        ActiveRecord::Base.establish_connection(dbconfig)

        def get_report()

            kst = "6553, 6555, 6557, 6558, 6562, 6560, 6563, 6564, 6565, 6566"
            first_of_month = "20130301"
            month = "Feb 2013"

            query = %Q{ select cc.CostCentreID Kostenstelle, cc.description Beschreibung, 
                               sum(jt.Costs) 'aufgelaufene Kosten', '#{month}' bis
                        from costcentre cc, jobtime jt
                        where cc.PrimaryKey = jt.FK_CostCentre
                          and cc.CostCentreID in (#{kst})
                          and jt.Date < '#{first_of_month}'
                        group by cc.CostCentreID, cc.description, '#{month}' }

            self.connection.select_all(query)

        end
    end
end
