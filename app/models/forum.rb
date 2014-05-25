class Forum < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }

  belongs_to :forumable, :polymorphic => true

  validates :name, :post, :category_ids, presence: true

  has_and_belongs_to_many :categories

  belongs_to :user

  has_many :comments, dependent: :destroy
  
  has_many :favorites, :as => :favoritable, dependent: :destroy

  before_create :create_slug

  def to_param
    slug
  end

  def create_slug
    self.slug = self.created_at.strftime("%d %m %Y").parameterize+"_"+self.name.parameterize
  end
end
