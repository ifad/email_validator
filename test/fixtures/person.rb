class Person < ActiveRecord::Base
  validates :email, :email => {:message => 'fails with custom message'},
                    :on    => :create
end

class MxRecord < ActiveRecord::Base
  validates :email, :email => {:check_mx => true},
                    :on    => :create
end
