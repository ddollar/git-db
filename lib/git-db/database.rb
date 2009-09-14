class GitDB::Database

  def self.couch
    @couch ||= CouchRest.new('http://localhost:5984')
  end

  def self.database(repository)
    @databases             ||= {}
    @databases[repository] ||= new(repository)
  end

  attr_reader :repository, :name, :database

  def initialize(repository)
    @repository = repository
    @name       = "gitdb-#{repository.gsub('/', '-')}"
    @database   = self.class.couch.database!(name)
    update_views
  end
  
## refs ######################################################################

  def get_ref(ref)
    doc = database.view('refs/all', :key => ref)['rows'].first
    doc ? doc['value'] : nil
  end

  def get_refs
    database.view('refs/all')['rows'].inject({}) do |hash, row|
      hash.update(row['key'] => row['value']['sha'])
    end
  end

  def write_ref(ref, sha)
    if doc = get_ref(ref)
      doc['sha'] = sha
      database.save_doc(doc)
    else
      database.save_doc(:doctype => 'ref', :ref => ref, :sha => sha)
    end
  end

  def delete_ref(ref)
    if doc = get_ref(ref)
      database.delete_doc(doc)
    end
  end

## objects ###################################################################

  def get_raw_object(sha)
    doc = database.view('objects/all', :key => sha)['rows'].first
    doc = doc ? decode_object(doc['value']) : nil
  end

  def get_object(sha)
    raw = get_raw_object(sha)
    raw ? GitDB::Objects.new_from_type(raw['type'], raw['data']) : nil
  end

  def write_object(object)
    doc = object_to_doc(object)
    doc = (get_raw_object(object.sha) || {}).merge(doc)
    database.save_doc(doc)
  end

  def write_objects(objects)
    docs = objects.map do |object|
      doc = object_to_doc(object)
      doc = (get_raw_object(object.sha) || {}).merge(doc)
    end
    database.bulk_save(docs)
  end

## utility ###################################################################

  def document_ids
    database.documents['rows'].map { |row| row['id']}
  end

  def encode_object(doc)
    doc['data'] = Base64.encode64(doc['data'])
    doc
  end

  def decode_object(doc)
    doc['data'] = Base64.decode64(doc['data'])
    doc
  end

  def object_to_doc(object)
    properties = object.properties
    properties += [:type, :data, :sha]
    doc = properties.inject({ :doctype => 'object' }) do |hash, property|
      hash.update(property.to_s => object.send(property))
    end
    encode_object(doc)
  end

  def update_views
    if document_ids.include?('_design/refs')
      database.delete_doc(database.get('_design/refs'))
    end
    database.save_doc({
      '_id'  => '_design/refs',
      :views => {
        :all => {
          :map => %{
            function(doc) {
              if (doc.doctype == 'ref') { emit(doc.ref, doc); }
            }
          }
        },
      }
    })
    if document_ids.include?('_design/objects')
      database.delete_doc(database.get('_design/objects'))
    end
    database.save_doc({
      '_id'  => '_design/objects',
      :views => {
        :all => {
          :map => %{
            function(doc) {
              if (doc.doctype == 'object') { emit(doc.sha, doc); }
            }
          }
        },
      }
    })
  end


end
