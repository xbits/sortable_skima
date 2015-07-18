Rails.application.routes.draw do

  match "sortable_data"=>"sortables#data_query"

end
