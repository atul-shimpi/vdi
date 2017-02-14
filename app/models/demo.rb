class Demo < ActiveRecord::Base
   belongs_to :demo_product
   belongs_to :configuration
end