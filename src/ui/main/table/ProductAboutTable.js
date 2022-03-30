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

import WebserviceUtil from '../../../uitl/WebserviceUtil';

import {Card} from 'react-native-shadow-cards';

import { Loading } from '../../../widget/Loading';


let {width, height} = Dimensions.get('window');

import PropTypes from 'prop-types';


import Swiper from 'react-native-swiper';



export default class ProductAboutTable extends Component {


  static propTypes = {
    product_detail: PropTypes.object,
    product_data :PropTypes.array,
  }


  constructor(props) {
      super(props);
      this.state = {
          userBean:undefined,
      }
    }


   UNSAFE_componentWillMount(){

      DeviceStorage.get('UserBean').then((user_bean) => {

        this.setState({
            userBean: user_bean,
        });

      });

   }


  description(){

  
    if (this.props.product_detail && this.props.product_detail.Product && this.props.product_detail.Product.how_help) {


      return (

        <View style = {{width:'100%'}}>


         <Text style = {styles.text_product_des}>Description</Text>


        <Text style = {styles.text_product_content}>{this.props.product_detail.Product.how_help}</Text>
            


        </View>


      );



    }else {

      return ( <View />);


    }

  }  



  suitable(){


    if (this.props.product_detail && this.props.product_detail.Product &&this.props.product_detail.Product.how_to_use) {


      return (

        <View style = {{width:'100%'}}>


          <Text style = {styles.text_product_des}>Description</Text>


          <Text style = {styles.text_product_content}>{this.props.product_detail.Product.how_to_use}</Text>
            
        </View>

      );


    }else {

      return (<View />);


    }

  }

  otherProducts(){


    if (this.props.product_data && this.props.product_data.length > 0) {

       var pages = [];

       for (var i = 0; i < this.props.product_data.length; i++) {


          if (this.props.product_data[i].length >= 2) {

            var xing1 = [];
            var xing2 = [];

            var avg_rating_1 = parseInt(this.props.product_data[i][0].avg_rating);
            var avg_rating_2 = parseInt(this.props.product_data[i][1].avg_rating);


            var picture1 = this.props.product_data[i][0].picture;
            var image_url1 = '';
            if (picture1) {
              image_url1 = picture1.slice(1,picture1.length);
            }


            var picture2 = this.props.product_data[i][1].picture;
            var image_url2 = '';
            if (picture2) {
              image_url2 = picture2.slice(1,picture2.length);
            }



            for (var j = 0; j < 5; j++) {

                if (j + 1  <=  avg_rating_1) {

                  xing1.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }else {

                  xing1.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/hui_xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }


                if (j + 1  <=  avg_rating_2) {

                  xing2.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }else {

                  xing2.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/hui_xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }
            }


            pages.push(

              <View  key = {i + ''}  style = {styles.view_product}>


                   <TouchableOpacity
                      style = {styles.view_product_item}  
                      onPress={this.clickProduct.bind(this,this.props.product_data[i][0])}>

                      <View style = {[styles.view_product_item,{marginRight:4}]}>

                          <View style = {{flex:1,height:120,flexDirection:'row-reverse'}}>

                              <View style = {styles.view_image_card}>

                                   <Image 
                                    style={{flex:1,borderRadius:16}}
                                    source={{uri: WebserviceUtil.getImageHostUrl() + image_url1}}
                                    resizeMode="cover" />


                              </View>

                              <TouchableOpacity
                                style = {styles.view_item_like}
                                onPress={this.clickLikeProduct.bind(this,this.props.product_data[i][0])}>


                                 <View style = {styles.view_item_like}>

                                    <Image
                                      style={{width:15,height:15}}
                                      source={this.props.product_data[i][0].isLike ? require('../../../../images/xing_hong_1223.png') : require('../../../../images/bai_xing.png')}
                                      resizeMode = 'contain' />


                                 </View>

                              </TouchableOpacity>   

                         </View>

                        <Text style = {styles.text_product_name} numberOfLines={1}>{this.props.product_data[i][0].alias ? this.props.product_data[i][0].alias : this.props.product_data[i][0].name}</Text>

                        <Text style = {styles.text_product_price} numberOfLines={1}>{'$' + this.props.product_data[i][0].sell_price}</Text>

                        <View style = {styles.view_xing}>

                          {xing1}

                        </View>

                    </View>

                  </TouchableOpacity>    




                <TouchableOpacity
                  style = {styles.view_product_item}  
                  onPress={this.clickProduct.bind(this,this.props.product_data[i][1])}>

                  <View style = {[styles.view_product_item,{marginLeft:4}]}>

                          <View style = {{flex:1,height:120,flexDirection:'row-reverse'}}>

                              <View style = {styles.view_image_card}>

                                  <Image 
                                    style={{flex:1,borderRadius:16}}
                                    source={{uri: WebserviceUtil.getImageHostUrl() + image_url2}}
                                    resizeMode="cover" />

                              </View>


                             <TouchableOpacity
                                style = {styles.view_item_like}
                                onPress={this.clickLikeProduct.bind(this,this.props.product_data[i][1])}>

                                <View style = {styles.view_item_like}>

                                    <Image
                                      style={{width:15,height:15}}
                                      source={this.props.product_data[i][1].isLike ? require('../../../../images/xing_hong_1223.png') : require('../../../../images/bai_xing.png')}
                                      resizeMode = 'contain' />

                                 </View>

                            </TouchableOpacity>    


                           

                         </View>

                        <Text style = {styles.text_product_name} numberOfLines={1}>{this.props.product_data[i][1].alias ? this.props.product_data[i][1].alias : this.props.product_data[i][1].name}</Text>

                        <Text style = {styles.text_product_price} numberOfLines={1}>{'$' + this.props.product_data[i][1].sell_price}</Text>

                        <View style = {styles.view_xing}>

                          {xing2}

                        </View>

                    </View>

                </TouchableOpacity>  
   
              </View>


              );

          }else {

            var xing1 = [];
            var avg_rating_1 = parseInt(this.props.product_data[i][0].avg_rating);

            var picture1 = this.props.product_data[i][0].picture;
            var image_url1 = '';
            if (picture1) {
              image_url1 = picture1.slice(1,picture1.length);
            }
      
            for (var j = 0; j < 5; j++) {

                if (j + 1  <=  avg_rating_1) {

                  xing1.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }else {

                  xing1.push(
                     <Image
                        key = {j + ''}
                        style={{width:15,height:15}}
                        source={require('../../../../images/hui_xingxing.png')}
                        resizeMode = 'contain' />
                  );

                }
            }


            pages.push(

              <View  key = {i + ''}  style = {styles.view_product}>


                  <View style = {[styles.view_product_item,{marginRight:4}]}>

                      <View style = {{flex:1,height:120,flexDirection:'row-reverse'}}>

                          <View style = {styles.view_image_card}>

                               <Image 
                                style={{flex:1,borderRadius:16}}
                                source={{uri: WebserviceUtil.getImageHostUrl() + image_url1}}
                                resizeMode="cover" />


                          </View>


                        <TouchableOpacity
                            style = {styles.view_item_like}
                            onPress={this.clickLikeProduct.bind(this,this.props.product_data[i][0])}>

                            <View style = {styles.view_item_like}>

                                <Image
                                  style={{width:15,height:15}}
                                  source={this.state.product_data[i][0].isLike ? require('../../../../images/xing_hong_1223.png') : require('../../../../images/bai_xing.png')}
                                  resizeMode = 'contain' />

                             </View>

                        </TouchableOpacity>      


                        
                     </View>

                    <Text style = {styles.text_product_name} numberOfLines={1}>{this.props.product_data[i][0].alias ? this.props.product_data[i][0].alias : this.props.product_data[i][0].name}</Text>

                    <Text style = {styles.text_product_price} numberOfLines={1} >{'$' + this.props.product_data[i][0].sell_price}</Text>

                    <View style = {styles.view_xing}>

                      {xing1}

                    </View>

                </View>



                <View style = {[styles.view_product_item,{marginLeft:4}]}>

                      

                </View>
      
              </View>


              );

          }


          
       }

      return (

        <View style = {styles.view_recently}>

          <View style = {styles.view_recently_title}>


            <Text style = {styles.text_recently_title}>Recently Viewed</Text>


            <Text style = {styles.text_view_all}></Text>

          </View>


          <Swiper
            loop={false}  
            height={257}
            index = {this.state.page}
            showsPagination={true} 
            paginationStyle={{bottom: 24}}
            autoplay={false} 
            horizontal={true}
            dot={<View style = {[styles.indicator_item,{backgroundColor:'#BDBDBD'}]}></View>}
            activeDot={<View style = {[styles.indicator_item,{backgroundColor:'#145A7C'}]}></View>}
            >

            {pages}

          </Swiper>   




        </View>


      );



    }else {


      return (<View/>);

    }
  }  


  clickProduct(product){


    DeviceEventEmitter.emit('product_detail_up',product.id);

    // const { navigation } = this.props;
   
    // if (navigation) {
    //   navigation.navigate('ShopProductDetailActivity',{
    //     'product_id':product.id
    //   });
    // }
  }


  clickLikeProduct(item){

    if(item.isLike){
      this.deleteLikeProduct(item.id);
    }else {
      this.saveLikeProduct(item.id);
    }


  }



  deleteLikeProduct(productId){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body>'+
    '<n0:deleteLikeProduct id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<productId i:type="d:string">'+ productId +'</productId>'+
    '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId><'+
    '/n0:deleteLikeProduct></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('product','deleteLikeProductResponse',data, function(json) {

        Loading.hidden();
        if (json && json.success == 1) {
           DeviceEventEmitter.emit('recently_viewed_change','ok');
        }

    });      
  } 

  saveLikeProduct(productId){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body>'+
    '<n0:saveLikeProduct id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<productId i:type="d:string">'+ productId +'</productId>'+
    '<clientId i:type="d:string">'+ this.state.userBean.id + '</clientId>'+
    '</n0:saveLikeProduct></v:Body></v:Envelope>';

    var temporary = this;
    Loading.show();
    WebserviceUtil.getQueryDataResponse('product','saveLikeProductResponse',data, function(json) {

        Loading.hidden();
        if (json && json.success == 1) {
          
           DeviceEventEmitter.emit('recently_viewed_change','ok');
        }

    });      



  }




render() {


     return(

      <View style = {styles.bg}>


        {this.description()}


        {this.suitable()}


        {this.otherProducts()}


      

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
  text_product_des:{
    width:'100%',
    color:'#145A7C',
    fontSize: 18,
    fontWeight: 'bold',
  },
  text_product_content:{
    marginTop:16,
    marginBottom:16,
    width:'100%',
    color:'#333333',
    fontSize: 14,
  },
  view_recently:{
    marginTop:24,
    width:'100%',
  },
  view_recently_title:{
    width:'100%',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  text_recently_title:{
    fontSize:24,
    fontWeight:'bold',
    color:'#145A7C'
  },
  text_view_all:{
    fontSize:14,
    color:'#C44729'
  },
  view_product:{
    marginTop:16,
    width:'100%',
    flexDirection: 'row',
  },
  view_product_item:{
    flex:1,
    height:180
  },
  view_image_card:{
    borderRadius:16,
    width:'100%',
    height:120,
    backgroundColor:'#F2F2F2'
  },
  view_item_like:{
    margin:8,
    borderRadius:50,
    width:25,
    height:25,
    backgroundColor:'#FFFFFF',
    position:'absolute',
    justifyContent: 'center',
    alignItems: 'center',
  },
  view_xing:{
    marginTop:4,
    width:'100%',
    flexDirection: 'row',
  },
  text_product_name:{
    width:'100%',
    fontSize:14,
    color:'#333',
    fontWeight:'bold',
  },
  text_product_price:{
    marginTop:4,
    width:'100%',
    fontSize:12,
    color:'#828282',
  },
   indicator_item:{
    width:24,
    height:4,
    backgroundColor:'#000000',
    borderRadius: 50,
    marginLeft:4,
  },
  xpop_cancel_confim:{
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
});
