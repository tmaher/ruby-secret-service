require 'dbus'

class SecretStorage
  SECRETS = 'org.freedesktop.secrets'
  SS_PREFIX = 'org.freedesktop.Secret.'
  SS_PATH = '/org/freedesktop/secrets'
  COLLECTION_PREFIX =  '/org/freedesktop/secrets/aliases/'
  DEFAULT_COLLECTION = "default"

  SERVICE_IFACE    = "#{SS_PREFIX}Service"
  COLLECTION_IFACE = "#{SS_PREFIX}Collection"
  ITEM_IFACE       = "#{SS_PREFIX}Item"

  ALGO = "plain"
  
  DBUS_UNKNOWN_METHOD  = 'org.freedesktop.DBus.Error.UnknownMethod'
  DBUS_SERVICE_UNKNOWN = 'org.freedesktop.DBus.Error.ServiceUnknown'
  DBUS_EXEC_FAILED     = 'org.freedesktop.DBus.Error.Spawn.ExecFailed'
  DBUS_NO_REPLY        = 'org.freedesktop.DBus.Error.NoReply'
  DBUS_NO_SUCH_OBJECT  = 'org.freedesktop.Secret.Error.NoSuchObject'

  attr_accessor :bus, :service, :session
  
  def initialize
    @bus = DBus::SessionBus.instance
    @service = @bus.service SECRETS

    @service_obj = @service.object SS_PATH
    @service_obj.introspect
    @service_obj.default_iface = SERVICE_IFACE
    
    @collections = {}
  end

  def init_session
    @service_obj.OpenSession(ALGO, "")
  end
  
  def get_collection(name=DEFAULT_COLLECTION)
    @collections[name.to_s] ||= Collection.new(@bus, name)
  end

end

class SecretStorage
  class Collection

    attr_accessor :collection, :session
    
    def initialize(bus, name = DEFAULT_COLLECTION)
      @bus = bus
      @collection_path = "#{COLLECTION_PREFIX}#{name}"
      @collection = bus.service(SECRETS).object(@collection_path)
      @collection.introspect
      @collection.default_iface = COLLECTION_IFACE
    end

    def get_unlocked_items(search_pred = {})
      @collection.SearchItems(search_pred)[0]
    end

    def get_locked_items(search_pref = {})
      @collection.SearchItems(search_pred)[1]
    end
  
  end
end

class SecretStorage
  class Item

    attr_accessor :item
    
    def initialize(bus, item_path)
      @bus = bus
      @item = bus.service(SECRETS).object(item_path)
      @item.introspect
      @item.default_iface = ITEM_IFACE
    end

    def get_secret
      @item.GetSecret(@bus)
    end
    
  end
end
