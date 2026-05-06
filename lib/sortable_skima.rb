require "sortable_skima/engine"
require "sortable_skima/base"
require "sortable_skima/serializer"
require "pagy"

module SortableSkima
  # Yield self on setup for nice config blocks
  def self.setup
    yield self
  end
end