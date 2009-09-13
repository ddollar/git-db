require 'base64'
require 'couchrest'
require 'logger'

module GitDB;

  def self.logger
    @logger ||= STDERR
  end

  def self.log(message)
    logger.puts message
  end

  def self.couch
    @couch ||= CouchRest.new('http://localhost:5984')
  end

  def self.database(repo)
    @databases ||= {}
    @databases[repo] ||= begin
      name = "gitdb-#{repo.gsub('/', '-')}"
      db = couch.database!(name)
      update_views(db)
      db
    end
  end

  def self.document_ids(database)
    database.documents['rows'].map { |row| row['id']}
  end

  def self.get_ref(repo, ref)
    doc = database(repo).view('refs/all', :key => ref)['rows'].first
    doc ? doc['value'] : nil
  end

  def self.get_refs(repo)
    database(repo).view('refs/all')['rows'].inject({}) do |hash, row|
      hash.update(row['key'] => row['value']['sha'])
    end
  end

  def self.write_ref(repo, ref, sha)
    if doc = get_ref(repo, ref)
      doc['sha'] = sha
      database(repo).save_doc(doc)
    else
      database(repo).save_doc(:doctype => 'ref', :ref => ref, :sha => sha)
    end
  end

  def self.delete_ref(repo, ref)
    if doc = get_ref(ref)
      database(repo).delete_doc(doc)
    end
  end

  def self.get_object(repo, sha)
    doc = database(repo).view('objects/all', :key => sha)['rows'].first
    if doc
      doc = decode_object(doc['value'])
      object = GitDB::Git::Objects.new_from_type(doc['type'], doc['data'])
    end
  end

  def self.encode_object(doc)
    doc['data'] = Base64.encode64(doc['data'])
    doc
  end

  def self.decode_object(doc)
    doc['data'] = Base64.decode64(doc['data'])
    doc
  end

  def self.object_to_doc(object)
    properties = object.properties
    properties += [:type, :data, :sha]
    doc = properties.inject({ :doctype => 'object' }) do |hash, property|
      hash.update(property.to_s => object.send(property))
    end
    encode_object(doc)
  end

  def self.write_object(repo, object)
    doc = object_to_doc(object)
    doc = (get_object(repo, object.sha) || {}).merge(doc)
    database(repo).save_doc(doc)
  end

  def self.write_objects(repo, objects)
    docs = objects.map do |object|
      doc = object_to_doc(object)
      doc = (get_object(repo, object.sha) || {}).merge(doc)
    end
    database(repo).bulk_save(docs)
  end

  def self.update_views(database)
    if document_ids(database).include?('_design/refs')
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
    if document_ids(database).include?('_design/objects')
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

require 'git'
require 'utility'
