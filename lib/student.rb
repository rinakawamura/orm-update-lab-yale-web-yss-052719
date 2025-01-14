require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id

  def initialize(name = nil, grade = nil, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
    SQL
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
      sql = "INSERT INTO students (name, grade) VALUES (?, ?);"
      DB[:conn].execute(sql, self.name, self.grade)
      @id =  DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    student = self.new
    student.id = row[0]
    student.name = row[1]
    student.grade = row[2]
    student
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM students WHERE name = ? LIMIT 1;"
    DB[:conn].execute(sql, name).map do |student|
      self.new_from_db(student)
    end.first
  end
  
  def update
    sql = "UPDATE students SET name = ?, grade = ? WHERE id = ?;"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end


end
