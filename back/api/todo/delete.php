<?php 
  header('Access-Control-Allow-Origin: *');
  header('Content-Type: application/json');
  header('Access-Control-Allow-Methods: DELETE');
  header('Access-Control-Allow-Headers: Access-Control-Allow-Headers,Content-Type,Access-Control-Allow-Methods, Authorization, X-Requested-With');

  include_once '../../config/Connection.php';
  include_once '../../models/Todo.php';


  $database = new Connection();
  $db = $database->connect();

  $todo = new Todo($db);

  $data = json_decode(file_get_contents("php://input"));

  if($todo->delete($data)) {
    echo json_encode(
      array('message' => 'Todo Deleted')
    );
  } else {
    echo json_encode(
      array('message' => 'Todo Not Deleted')
    );
  }

