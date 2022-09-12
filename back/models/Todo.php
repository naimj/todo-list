<?php
class Todo {
  private $conn;
  private $table = 'todo';
  public $id;
  public $title;
  public $description;
  public $validate;
  public $terminate;

  public function __construct($db) {
    $this->conn = $db;
  }

  public function create($data) {
    $query = 'INSERT INTO ' . $this->table .'(title, description, validate, terminate) VALUES (:title, :description, 1, 0)';
    $stmt = $this->conn->prepare($query);

    try {
      foreach($data as $item) {
        $stmt->bindParam(':title', $item->title);
        $stmt->bindParam(':description', $item->description);
        $stmt->execute();
      }

      return true;

    } catch(Exception $e) {
      return false;
    }
  }

  public function read() {
    $query = 'SELECT * FROM ' . $this->table;
    $stmt = $this->conn->prepare($query);

    $stmt->execute();

    return $stmt;
  }

  public function delete($data) {
    $query = 'DELETE FROM ' . $this->table . ' WHERE id = :id';

    $stmt = $this->conn->prepare($query);

    try {
      foreach($data as $item) {
        $stmt->bindParam(':id', $item->id);
        $stmt->execute();
      }

      return true;

    } catch(Exception $e) {
      return false;
    }
  }

  public function update($data) {
    $query = 'UPDATE ' . $this->table . ' SET terminate = :terminate WHERE id = :id';
    $stmt = $this->conn->prepare($query);
  
    try {
      foreach($data as $item) {
        $stmt->bindParam(':terminate', $item->terminate);
        $stmt->bindParam(':id', $item->id);
        $stmt->execute();
      }

      return true;

    } catch(Exception $e) {
      return false;
    }
  }
}
