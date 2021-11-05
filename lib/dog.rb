class Dog

    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
      @id = id
      @name = name
      @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
      DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL
      DB[:conn].execute(sql)
    end

    def save
      if self.id
        self
      else
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL
  
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
      end
    end

    def self.create(attr_hash)
      dog = self.new(name: attr_hash[:name], breed: attr_hash[:breed])
      dog.save
    end

    def self.new_from_db(hash)
      new_dog = self.new(id: hash[0], name: hash[1], breed: hash[2])
      new_dog
    end

    def self.find_by_id(id)
      sql = <<-SQL 
        SELECT * FROM dogs WHERE id = ?
      SQL

      result = DB[:conn].execute(sql, id).first
      Dog.new(id: result[0], name: result[1], breed: result[2])
    end

    def self.find_or_create_by(hash)
      sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?
      SQL
  
      arr = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten
      if !arr.empty?
        dog = self.new(id: arr[0], name: arr[1], breed: arr[2])
      else
        dog = self.create(hash)
      end
      dog
    end

    def self.find_by_name(name)
      sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?
      SQL

      arr = DB[:conn].execute(sql, name).first
      Dog.new(id: arr[0], name: arr[1], breed: arr[2])
    end

    def update
      sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
      SQL
  
      dog = DB[:conn].execute(sql, self.id).first
  
      update = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
      SQL
  
      DB[:conn].execute(update, self.name, self.breed, self.id)
    end
end
