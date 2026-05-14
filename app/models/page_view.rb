class PageView < ApplicationRecord
  belongs_to :user, optional: true

  scope :today, -> { where(created_at: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :this_week, -> { where(created_at: 1.week.ago.beginning_of_day..Time.current.end_of_day) }
  scope :this_month, -> { where(created_at: 1.month.ago.beginning_of_day..Time.current.end_of_day) }
end
