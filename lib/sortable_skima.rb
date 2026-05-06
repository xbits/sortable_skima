require "sortable_skima/engine"
require "pagy"
require "pagy/backend"
require "sortable_skima/base"
require "sortable_skima/serializer"

module SortableSkima
  # Yield self on setup for nice config blocks
  def self.setup
    yield self
  end
end