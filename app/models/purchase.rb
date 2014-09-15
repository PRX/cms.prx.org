class Purchase < BaseModel
  belongs_to :purchased, class_name: 'Story'
  belongs_to :purchaser, class_name: "User", with_deleted: true
  belongs_to :purchaser_account, class_name: "Account", with_deleted: true
  belongs_to :seller_account, class_name: "Account", with_deleted: true
end
