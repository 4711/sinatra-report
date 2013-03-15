require 'mysql2'
require 'active_record'
require 'sinatra'
require 'csv'
require 'json'
require 'xmlsimple'
require 'haml'
require 'sinatra/respond_to'
require 'sinatra/prawn'

set :prawn, { :page_layout => :landscape }

Sinatra::Application.register Sinatra::RespondTo

get '/' do
    haml :index
end

get '/pdf' do
    content_type 'application/pdf'
    prawn :pdf
end

get '/report/?:year?/?:month?' do
    format_response MyAPI.get_report(params)
end

post '/report' do
    format_response MyAPI.get_report(params)
end

get '/chart' do
    haml :chart
end

def format_response(data)
    @costs = data
    respond_to do |format|
        format.html { haml :report, :locals => { :costs => data.to_s } }
#        format.html  { data.to_s }
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

        def get_report(params)

            kst = "6553, 6555, 6557, 6558, 6562, 6560, 6563, 6564, 6565, 6566"

            month = params[:month].nil? ? Date.today.month : params[:month].to_i
            year = params[:year].nil? ? Date.today.year : params[:year].to_i

            month_field = (Date.new(year, month, 1)-1).strftime("%Y.%m.%d")
            first_of_month = Date.new(year, month, 1).strftime("%Y%m%d")

            query = %Q{ select cast(cc.CostCentreID as UNSIGNED) Kostenstelle,
                               cc.description Beschreibung, 
                               sum(jt.Costs) 'Kosten', 
                               '#{month_field}' Bis 
                        from costcentre cc left outer join jobtime jt on cc.PrimaryKey = jt.FK_CostCentre
                        where cc.CostCentreID in (#{kst})
                          and jt.Date < '#{first_of_month}'
                        group by cc.CostCentreID, cc.description, '#{month_field}' }

            self.connection.select_all(query)

        end
    end
end

__END__

@@ pdf
pdf.text "Hello world!!!!!"

