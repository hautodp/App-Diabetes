import 'dart:convert';

import 'package:diabetesapp/models/food-recipe.dart';
import 'package:diabetesapp/models/food.dart';
import 'package:diabetesapp/screens/advice/recommend_screens/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../constants.dart';

// ignore: must_be_immutable
class RecipeFood extends StatefulWidget {
  static String routeName = "/recipe_food_screen";
  FoodModel foodModel;
  RecipeFood({this.foodModel});
  @override
  _RecipeFoodState createState() {
    // TODO: implement createState
    return new _RecipeFoodState(recipeFood: foodModel);
  }
}
class _RecipeFoodState extends State<RecipeFood> {
  _RecipeFoodState({this.recipeFood});
  FoodRecipeModel foodRecipeModel = new FoodRecipeModel(id: "", name: "", ingredient: "", recipe: "", benefit: "", groupID: "");
  FoodModel recipeFood;
  @override
  void initState() {
    fetchRecipe();
  }
  fetchRecipe() async {
    String url = ip + "/api/getRecipeByID.php";
    var response = await http.post(url, body: {
      'groupID': recipeFood.id,
    });

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      FoodRecipeModel item = FoodRecipeModel.fromJson(items[0]);
      setState(() {
        foodRecipeModel = item;
      });
    } else {
      throw Exception('Failed to load data.');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
          tooltip: 'Đóng',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // actions: [
        //   Padding(
        //     padding: EdgeInsets.only(right: 16),
        //     child: Icon(
        //       Icons.favorite_border,
        //       color: Colors.white,
        //     ),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextTitleVariation1(widget.foodModel.name),
                  buildTextTitleVariation2("Công dụng", false),
                  buildTextSubTitleVariation1(foodRecipeModel.benefit),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              height: 310,
              width: 310,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(widget.foodModel.image),
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextTitleVariation2("Thành phần dinh dưỡng", false),
                  buildTextSubTitleVariation1("Chất béo: " + recipeFood.lipid + " g"),
                  buildTextSubTitleVariation1("Chất xơ: " + recipeFood.cellulose + " g"),
                  buildTextSubTitleVariation1("Carbon Hydrat: " + recipeFood.carb + " g"),
                  buildTextSubTitleVariation1("Chất đạm: " + recipeFood.protein + " g"),
                  (foodRecipeModel.ingredient.length > 0) ?
                  Column(
                    children: [
                      buildTextTitleVariation2('Nguyên liệu', false),
                      buildTextSubTitleVariation1(foodRecipeModel.ingredient),
                    ],
                  ) : SizedBox(height: 1,),
                  SizedBox(height: 16),
                  (foodRecipeModel.recipe.length > 0) ?
                  Column(
                    children: [
                      buildTextTitleVariation2('Cách làm', false),
                      buildTextSubTitleVariation1(foodRecipeModel.recipe),
                    ],
                  ) : SizedBox(height: 1,)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}