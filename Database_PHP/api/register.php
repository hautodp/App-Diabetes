<?php
    include("config.php");
    include("Account.php");

    $account = new Account($con);

    $fullname = $_POST['fullname'];
    $email = $_POST['email'];
    $phone = $_POST['phone'];
    $password = $_POST['password'];

    $sql = "SELECT *FROM users WHERE email = '".$email."'";
    $result = mysqli_query($con,$sql);
    $count = mysqli_num_rows($result);

    if($count >=1){
        if($password=="apaaja"){
            echo json_encode("Exist");
        }else{
            echo json_encode(("Error"));
        }
    }else{
        $query = $account->register($fullname,$email,$phone,$password);

        if($query){
            echo json_encode("Success");
        }
    }
?>