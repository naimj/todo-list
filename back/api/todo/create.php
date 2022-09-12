<?php 
  header('Access-Control-Allow-Origin: *');
  header('Content-Type: application/json');
  header('Access-Control-Allow-Methods: POST');
  header('Access-Control-Allow-Headers: Access-Control-Allow-Headers,Content-Type,Access-Control-Allow-Methods, Authorization, X-Requested-With');

  include_once '../../config/Connection.php';
  include_once '../../models/Todo.php';

  $database = new Connection();
  $db = $database->connect();

  $todo = new Todo($db);

  $data = json_decode(file_get_contents("php://input"));

  if($todo->create($data)) {
    echo json_encode(
      array('message' => 'Todo Created')
    );
  } else {
    echo json_encode(
      array('message' => 'Todo Not Created')
    );
  }