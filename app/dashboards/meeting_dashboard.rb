require "administrate/base_dashboard"

class MeetingDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    bookings: Field::HasMany,
    description: Field::Text,
    duration: Field::Number,
    image: Field::String,
    password: Field::String,
    price: Field::Number,
    start_time: Field::DateTime,
    topic: Field::String,
    zoom_id: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    topic
    start_time
    duration
    bookings
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    topic
    image
    description
    start_time
    duration
    password
    price
    zoom_id
    bookings
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    topic
    image
    description
    start_time
    duration
    price
    zoom_id
    password
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how meetings are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(meeting)
  #   "Meeting ##{meeting.id}"
  # end

  def display_resource(meeting)
    meeting.topic.truncate(20)
  end
end
