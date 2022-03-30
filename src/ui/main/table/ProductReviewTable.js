
import React, {
  Component
} from 'react';
import {
  SafeAreaView,
  Platform,
  StyleSheet,
  Text,
  View,
  ImageBackground,
  Image,
  TextInput,
  Button,
  TouchableOpacity,
  TouchableHighlight,
  ScrollView,
  StatusBar,
  AsyncStorage,
  StackAction,
  NavigationActions,
  DeviceEventEmitter,
  Dimensions,
  FlatList,
} from 'react-native';


import DeviceStorage from '../../../uitl/DeviceStorage';

import DateUtil from '../../../uitl/DateUtil';

import StringUtils from '../../../uitl/StringUtils';

import WebserviceUtil from '../../../uitl/WebserviceUtil';

import {Card} from 'react-native-shadow-cards';


let {width, height} = Dimensions.get('window');

import PropTypes from 'prop-types';


import Swiper from 'react-native-swiper';



export default class ProductReviewTable extends Component {


  	static propTypes = {
    	product_review_detail: PropTypes.object,
  	}


  	constructor(props) {
      super(props);
      this.state = {
        product_review_detail:undefined,
        product_reviews:[],
      }
    }


    static  getDerivedStateFromProps(props, state) {
          if (props.product_review_detail) {

            return {
              product_review_detail:props.product_review_detail,
              product_reviews:props.product_review_detail.Reviews,
            }

          }else {
             return null
          }
       
    }

    reviewInfoView(){


      if (this.state.product_reviews && this.state.product_reviews.length > 0) {

          var xing = [];
          var avg_rating_int = 0;

          try{
            avg_rating_int = parseInt(this.state.product_review_detail.avg_rating);
          }catch(e){

          }

          for (var j = 0; j < 5; j++) {

              if (j + 1  <=  avg_rating_int) {

                xing.push(
                   <Image
                      key = {j + ''}
                      style={{width:15,height:15}}
                      source={require('../../../../images/xingxing.png')}
                      resizeMode = 'contain' />
                );

              }else {

                xing.push(
                   <Image
                      key = {j + ''}
                      style={{width:15,height:15}}
                      source={require('../../../../images/hui_xingxing.png')}
                      resizeMode = 'contain' />
                );

              }
          } 


          return (

            <View style = {styles.view_reviews}>


              <Text style = {styles.text_sustomers}>{this.props.product_review_detail.Counts} Customer Ratings</Text>

              <Text style = {styles.text_rating}>{StringUtils.toDecimal1(this.props.product_review_detail.avg_rating)}</Text>


                 <View style = {styles.view_xing}>

                    {xing}       

                </View>

                <Text style = {styles.text_review_title}>Customer Ratings</Text>


                <FlatList
                  nestedScrollEnabled = {true}
                  style = {{flex:1,width:'100%'}}
                  ref = {(flatList) => this._flatList = flatList}
                  renderItem = {this._renderItem}
                  onEndReachedThreshold={0}
                  keyExtractor={(item, index) => index.toString()}
                  data={this.state.product_reviews}/>
         
            </View>

            );

      }else {

        return (<Text style = {styles.text_no_data}>No reviews yet</Text>);


      }




    }



    _renderItem = (item) => {


      var rating = 0;

      try{

        rating = parseInt(item.item.rating);

      }catch(e){


      }


     return(
     
        <View style = {styles.view_reviews_item}>


              <Text style = {styles.text_user_name}>{item.item.first_name + ' ' + item.item.last_name}</Text>


              <View style = {styles.view_xing}>

                <Text style = {styles.text_item_xing}>{rating}</Text>  

                <Image
                    style={{width:15,height:15}}
                    source={require('../../../../images/xingxing.png')}
                    resizeMode = 'contain' />

                    
              </View>


              <Text style = {styles.text_user_content}>{item.item.review_content}</Text>


              <Text style = {styles.text_date}>{DateUtil.getShowTimeFromDate4(item.item.create_time)}</Text>

        </View>   


     ); 




    }


	render() {

	 	return(

	 		 <View style = {styles.bg}>

	 		 	{this.reviewInfoView()}

	 		 </View>



	 	 );

	}

}


const styles = StyleSheet.create({

  bg: {
    flex:1,
    padding:24,
    backgroundColor:'#FFFFFF',
  },
  text_no_data:{
  	marginTop:36,
  	width:'100%',
  	fontSize:16,
    color:'#BDBDBD',
    fontWeight:'bold',
    textAlign:'center',
  },
  xpop_cancel_confim:{
  	marginTop:50,
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom:74,
  },
  xpop_item:{
    borderRadius: 50,
    height:44,
   
    justifyContent: 'center',
    alignItems: 'center',
  },
  xpop_text: {
    fontSize:14,
    textAlign :'center',
    fontWeight: 'bold',
  },
  xpop_touch:{
     width:'48%',

  },
  view_reviews:{
  	width: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },
  view_reviews_item:{
  	marginTop:16,
  	width:'100%',
  	padding:20,
  	borderRadius:16,
  	backgroundColor:'#FAF3EB'
  },
  text_sustomers:{
  	fontSize:13,
    color:'#333333', 
  },
  text_rating:{
  	marginTop:8,
  	fontSize:24,
    color:'#333333',
    fontWeight:'bold',
    textAlign:'center',
  },
  view_xing:{
  	marginTop:8,
  	flexDirection: 'row',
  },
  text_review_title:{
  	marginTop:33,
  	width:'100%',
  	fontSize:18,
    color:'#145A7C',
    fontWeight:'bold',
  },
  text_user_name:{
  	marginTop:6,
  	fontSize:18,
    color:'#145A7C',
    fontWeight:'bold',
  },
  text_item_xing:{
  	marginRight:5,
  	marginBottom:2,
  	fontSize:16,
    color:'#4F4F4F',
  },
  text_user_content:{
  	marginTop:32,
  	fontSize:16,
    color:'#4F4F4F',
  },
  text_date:{
  	marginTop:10,
  	fontSize:16,
    color:'#BDBDBD',
  }
});



