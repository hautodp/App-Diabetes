<?php
    class Weight{
        public function __construct1($id,$weight,$tags,$note,$measureTime,$userID){
            $this->id=$id;
            $this->weight=$weight;
            $this->tags=$tags;
            $this->note=$note;
            $this->measureTime=$measureTime;
            $this->userID=$userID;
        }

        public function __construct($con)
        {
            $this->con=$con;
        }

        public function insertWeight($weight,$tags,$note,$measureTime,$userID){

            $result=mysqli_query($this->con, "INSERT INTO weights VALUES ('','$userID','$tags','$note','$weight','$measureTime')");
            return $result;
        }

        public function updateWeight($id,$weight,$tags,$note,$measureTime){

            $query = "UPDATE weights SET weight='$weight', tags='$tags', note='$note', measureTime='$measureTime'  WHERE id='$id'";
            $result=mysqli_query($this->con, $query);
            return $result;
        }

        public function deleteWeight($id){
            $query = "DELETE FROM weights WHERE id='$id'";
            $result=mysqli_query($this->con, $query);
            return $result;
        }
    }
?>