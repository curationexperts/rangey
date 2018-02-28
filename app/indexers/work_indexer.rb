# Generated via
#  `rails generate hyrax:work Work`
class WorkIndexer < Hyrax::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata


  # Uncomment this block if you want to add custom indexing behavior:
  def generate_solr_document
   super.tap do |solr_doc|
     solr_doc['year_iim'] = extract_years(object.date_created)
   end
  end

  def extract_years(dates)
    dates.flat_map{ |d| extract_year(d) }.uniq
  end

  def extract_year(date)
    date = date.to_s
    if date.blank?
      nil
    elsif /^\d{4}$/ =~ date
      # Date.iso8601 doesn't support YYYY dates
      date.to_i
    elsif /^\d{4}-\d{4}$/ =~ date
      # date range in YYYY-YYYY format
      earliest, latest = date.split('-').flat_map{ |y| y.to_i }
      (earliest..latest).to_a
    else
      Date.iso8601(date).year
    end
  rescue ArgumentError
    raise "Invalid date: #{date.inspect} in #{inspect}"
  end
end
