<?php 
  // Headers
  header('Access-Control-Allow-Origin: *');
  header('Content-Type: application/json');

  include_once '../../config/Connection.php';
  include_once '../../models/Todo.php';

  $database = new Connection();
  $db = $database->connect();

  $todos = new Todo($db);

  $result = $todos->read();
  $num = $result->rowCount();

  if($num > 0) {
    $todos_arr = array();

    while($row = $result->fetch(PDO::FETCH_ASSOC)) {
      extract($row);

      $todo_item = array(
        'id' => $id,
        'title' => $title,
        'description' => $description,
        'validate' => $validate,
        'terminate' => $terminate
      );

      array_push($todos_arr, $todo_item);
    }

    echo json_encode(
      array('message' => 'Found Todo', 'data' => $todos_arr)
      );

  } else {
    echo json_encode(
      array('message' => 'No Todo Found')
    );
  }
