require 'csv'
require 'open-uri'

class GeoByIP
  KEY = '3770cd36f975c11893ca5019d3e11dadaf8db640e2a96c6358d029aed90a1b63'
  URL = 'http://api.ipinfodb.com/v3/ip-city/'
  # URL needs key and ip params

  def initialize
    @output_file = "#{File.expand_path('.')}/output.csv"
  end

  def lookup(path)
    started = false
    index = 0
    CSV.open(@output_file, 'a') do |csv|
      CSV.foreach(path) do |row|
        unless started
          row << ["IP for Verification", "Country", "Country Code", "State", "City", "Zip Code", "Latitude", "Longitude", "GMT Offset"]
          started = true
        else
          puts "Looking up #{row[0]}, number #{index}"
          open("#{URL}?key=#{KEY}&ip=#{row[0]}") do |f|
            result = f.read.split(';')
            if result[0] == 'OK'
              row << result[2..-1]
            end
          end
        end
        row.flatten!
        csv << row
        index += 1
      end
    end
  end

end


describe GeoByIP do
  # it "generates an output file" do
  #   GeoByIP.new
  #   output_file = "#{File.expand_path('.')}/output.csv"
  #   puts output_file
  #   expect(File.exists?(output_file)).to be_true
  #   `rm output.csv`
  # end

  # it "reads CSV files line by line" do
  #   geolocator = GeoByIP.new
  #   lines = geolocator.read('poll.csv')
  #   expect(lines.size).to eq 35480
  # end

  it "looks up detailed IP info" do
    geolocator = GeoByIP.new
    geolocator.lookup('poll.csv')
  end
end
