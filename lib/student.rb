require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade, :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(id = nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER);"

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE students;"

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      insert = "INSERT INTO students (name, grade)
        VALUES (?, ?);"

      DB[:conn].execute(insert, self.name, self.grade)
      
      id_query = "SELECT last_insert_rowid() FROM students"
      self.id = DB[:conn].execute(id_query)[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    grade = row[2]
    name = row[1]
    id = row[0]
    student = Student.new(id, name, grade)
  end

  def self.find_by_name(name)
    search_query = "SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1;"
    
    self.new_from_db(DB[:conn].execute(search_query, name)[0])
  end

  def update
    update_query = "UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?;"

    DB[:conn].execute(update_query, self.name, self.grade, self.id)
  end
end
