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
  FlatList,
  Button,
  TouchableOpacity,
  TouchableHighlight,
  ScrollView,
  StatusBar,
  AsyncStorage,
  StackAction,
  NavigationActions,
  DeviceEventEmitter,
  NativeModules,
  RefreshControl
} from 'react-native';


import WebserviceUtil from '../../../uitl/WebserviceUtil';

import { Loading } from '../../../widget/Loading';

import { toastShort } from '../../../uitl/ToastUtils';

import DateUtil from '../../../uitl/DateUtil';

import DeviceStorage from '../../../uitl/DeviceStorage';

import IparInput from '../../../widget/IparInput';

import CoverLayer from '../../../widget/xpop/CoverLayer';

import CheckBox from 'react-native-check-box'

import StringUtils from '../../../uitl/StringUtils';

import ProductAboutTable from '../table/ProductAboutTable';

import ProductReviewTable from '../table/ProductReviewTable';



let nativeBridge = NativeModules.NativeBridge;

import ScrollableTabView, {ScrollableTabBar, DefaultTabBar} from 'react-native-scrollable-tab-view';


export default class ShopProductDetailActivity extends Component {


    constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       product_id:undefined,
       product_detail:undefined,
       product_num:1,
       product_data:[],
       products_cart_count:0,
       product_review_detail:undefined,
       table_page:0,
       isRefreshing:false,
    }
  }

  UNSAFE_componentWillMount(){

  
    DeviceStorage.get('head_company_id').then((ompany_id) => {


      if (ompany_id) {
        this.setState({
            head_company_id: ompany_id,
          });
      }else {
        this.setState({
            head_company_id: '97',
          });

      }
    });

    this.cartCount();
    if (this.props.product_id) {
      this.setState({
        product_id:this.props.product_id,
      });

      this.getProductsDetails(this.props.product_id);
      this.getProductsReviews(this.props.product_id);

    }else {
      if (this.props.route.params) {
        this.setState({
          product_id:this.props.route.params.product_id,
        });
  
        this.getProductsDetails(this.props.route.params.product_id);
        this.getProductsReviews(this.props.route.params.product_id);
      }
    }
    
    DeviceStorage.get('UserBean').then((user_bean) => {

      this.setState({
          userBean: user_bean,
      });

    });

   
  }


  cartCount(){

     DeviceStorage.get('shop_cart').then((cart_json) => {

        var carts = [];

        if (cart_json) {

            carts = JSON.parse(cart_json,'utf-8');
        }
        
        this.setState({
          products_cart_count:carts.length,
        });


      });

  }




   //注册通知
  componentDidMount(){

    var temporary = this;

    this.emit =  DeviceEventEmitter.addListener('product_detail_up',(params)=>{
          //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
         temporary.setState({
             product_id:params,
         });

        temporary.getProductsDetails(params);
        temporary.getProductsReviews(params);


        // 滑倒顶部
        temporary.setScrollView();


     });


     this.emit1 =  DeviceEventEmitter.addListener('shop_cart_up',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
           temporary.cartCount();
       });

      this.emit2 =  DeviceEventEmitter.addListener('recently_viewed_change',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
            temporary.getRecommendProducts();
       });

  }

  componentWillUnmount(){
    this.emit.remove();
    this.emit1.remove();
    this.emit2.remove();
  }

  setScrollView(){

   this.scrollView.scrollTo({x:0,y:0});

  }




  getProductsDetails(product_id){

    if (!product_id) {
      return;
    }

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getProductsDetails id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<id i:type="d:string">'+ product_id +'</id>'+
    '<reviewLimit i:type="d:string">2</reviewLimit>'+
    '</n0:getProductsDetails></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('product','getProductsDetailsResponse',data, function(json) {

        if (json && json.success == 1) {
           temporary.setState({
              product_detail:json.data, 
           });

           temporary.getRecommendProducts();
           temporary.saveRecentViewedProduct();
        }

    });      
  }


  saveRecentViewedProduct(){

     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
     '<v:Header />'+
     '<v:Body><n0:saveRecentViewedProduct id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
     '<productId i:type="d:string">'+ this.state.product_id +'</productId>'+
     '<clientId i:type="d:string">'+ this.state.userBean.id  +'</clientId>'+
     '</n0:saveRecentViewedProduct></v:Body></v:Envelope>';

      var temporary = this;
      WebserviceUtil.getQueryDataResponse('product','saveRecentViewedProductResponse',data, function(json) {

        
      });      




  }


  getProductsReviews(product_id){

      var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/">'+
      '<v:Header />'+
      '<v:Body>'+
      '<n0:getProductsReviews id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
      '<offset i:type="d:string">20</offset>'+
      '<id i:type="d:string">'+ product_id +'</id>'+
      '<start i:type="d:string">0</start></n0:getProductsReviews></v:Body></v:Envelope>';

      var temporary = this;
      WebserviceUtil.getQueryDataResponse('product','getProductsReviewsResponse',data, function(json) {

          
          if (json && json.success == 1  && json.data) {

            temporary.setState({
                product_review_detail:json.data,
            });
             
          }
      });      
    }




getRecommendProducts(){

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getRecommendProducts id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">'+ this.state.head_company_id + '</companyId>'+
    '<productId i:type="d:string">'+ this.state.product_id +'</productId>'+
    '<isOnline i:type="d:string">1</isOnline>'+
    '<limit i:type="d:string">4</limit>'+
    '<clientId i:type="d:string">'+ this.state.userBean.id +'</clientId>'+
    '</n0:getRecommendProducts></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('product','getRecommendProductsResponse',data, function(json) {

       if (json && json.success == 1 && json.data) {
            
            var products = [];
            var product_chien = [];

            for (var i = 0; i < json.data.length; i++) {
             
                if (i % 2 == 0) {

                  if (product_chien.length > 0) {
                      products.push(product_chien);
                  }
                  product_chien = [];

                }

                product_chien.push(json.data[i]);

            }

            if (product_chien.length > 0) {
              products.push(product_chien);
            }

            temporary.setState({
              product_data:products,
            });

            
        }else {
          temporary.setState({
              product_data:[],
            });
        }      

    });      


  }



  back(){

    if (this.props.navigation) {
      this.props.navigation.goBack();
    }else {
      nativeBridge.goBack();
    }
    

  }

  clickLike(){

    if (this.props.isNative) {
      NativeModules.NativeBridge.openNativeVc("RNBridgeViewController",{pageName:"ShopLikeActivity"});
    }else {
      const { navigation } = this.props;
   
      if (navigation) {
        navigation.navigate('ShopLikeActivity');
      }
    }


  }


  clickCar(){

    if (this.props.isNative) {
      NativeModules.NativeBridge.openNativeVc("RNBridgeViewController",{pageName:"ProductCartActivity",property:{'product_detail':undefined,'buy_now':0}});
    }else {
      const { navigation } = this.props;

      if (navigation) {
        navigation.navigate('ProductCartActivity',{
          'product_detail':undefined,
          'buy_now':0,
        });
      }
    }
    

  }

  clickNumAdd(){

    if (this.state.product_num <= 99) {

      this.setState({
        product_num:this.state.product_num + 1,
      });

    }

  }



clickAddCart(){

  DeviceStorage.get('shop_cart').then((cart_json) => {

    var carts = [];

    if (cart_json) {

        carts = JSON.parse(cart_json,'utf-8');
    }

    var isInCart = false;

    for (var i = 0; i < carts.length; i++) {
      var cart =  carts[i];

      if (cart.Product.id == this.state.product_detail.Product.id) {
          isInCart = true;
      }
    }

    if (isInCart) {
      toastShort('The Product is already in the shopping cart！');
    }else {
      toastShort('Add SuccessFully');

      var product_detail = this.state.product_detail;
      product_detail.product_num = this.state.product_num;
      carts.push(product_detail);

      //
      DeviceStorage.save('shop_cart', JSON.stringify(carts));
      DeviceEventEmitter.emit('shop_cart_up','ok');
    }

  });




}

clickBuyNow(){

  if (this.props.isNative && this.state.product_detail) {

    var product_detail = this.state.product_detail;

    product_detail.product_num = this.state.product_num;

    NativeModules.NativeBridge.openNativeVc('RNBridgeViewController',{pageName:'ProductCartActivity',property:{
      'product_detail':product_detail,
      'buy_now':1,
    }})
    return
  }

  const { navigation } = this.props;

  if (navigation && this.state.product_detail) {

    var product_detail = this.state.product_detail;

    product_detail.product_num = this.state.product_num;

    navigation.navigate('ProductCartActivity',{
      'product_detail':product_detail,
      'buy_now':1,
    });
  }

}





  clickNumJian(){

    if (this.state.product_num > 1) {

      this.setState({
        product_num:this.state.product_num - 1,
      });

    }


  }


  _cartCountView(){


    if (this.state.products_cart_count > 0) {


      return (

           <View style = {{width:20,height:20, position:'absolute'}}>

            <View style = {{width:15,height:15,backgroundColor:'#C44729',borderRadius: 50,marginLeft:8,marginBottom:5,justifyContent: 'center',alignItems: 'center',}}>

                  <Text style = {{color:'#FFFFFF',fontSize:10}}>{this.state.products_cart_count}</Text>
            </View>       
          </View>


      );

    }else {


      return (<View/>);

    }


  }



  clickTablePage(page){

    if (page != this.state.table_page) {


      this.setState({

        table_page : page,

      });


    }



  }






   render() {

     var image_url = '';
     var xing = [];
     var avg_rating = '0.0';

    if (this.state.product_detail) {

      
       var picture = this.state.product_detail.Product.picture;

       if (picture && picture.length > 0) {
         image_url = picture.slice(1,picture.length);
       }

        var avg_rating = this.state.product_detail.Product.avg_rating;

        var avg_rating_int = 0;

        if (avg_rating && avg_rating.length > 0) {
            
        }else {
          avg_rating = '0.0';
        }

         avg_rating_int = parseInt(avg_rating);

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

     


    }

  
      return(

         <View style = {styles.bg}>

            <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />

            <SafeAreaView style = {styles.afearea} >

             <View style = {styles.header}>


               <View style = {styles.view_car_like}>

                   <TouchableOpacity  
                      onPress={this.back.bind(this)}>
                      <View style ={styles.rightView} >
                          <Image
                            style={{width:8,height:12}}
                            source={require('../../../../images/left_0909.png')}
                            resizeMode = 'contain' />
                      </View>

                    </TouchableOpacity>


                      <View style ={styles.rightView} />


               </View>


               <Text style = {styles.text_title}>Shop</Text> 


               <View style = {styles.view_car_like}>


                  <TouchableOpacity  
                    onPress={this.clickLike.bind(this)}>
                    <View style ={styles.rightView} >
                        <Image
                          style={{width:20,height:20}}
                          source={require('../../../../images/baise_aixin.png')}
                          resizeMode = 'contain' />
                    </View>

                  </TouchableOpacity>


                  <TouchableOpacity  
                    onPress={this.clickCar.bind(this)}>
                    <View style ={styles.rightView} >
                        <Image
                          style={{width:20,height:20}}
                          source={require('../../../../images/baise_gouwuche.png')}
                          resizeMode = 'contain' />

                          {this._cartCountView()}
                    </View>
                  </TouchableOpacity>

               </View>

           </View>



           <ScrollView 
              ref={ref => this.scrollView = ref}
              style = {styles.scrollview}
              stickyHeaderIndices={[1]}
              showsVerticalScrollIndicator = {false}>


              <View style = {styles.view_product_head}>

                  <View style = {styles.view_product_image}>

                    <Image 
                      style={{flex:1}}
                      source={{uri: WebserviceUtil.getImageHostUrl()  + image_url }}
                      resizeMode="cover" />


                  </View>



                  <View style = {styles.view_product_info}>


                    <Text style = {styles.text_product_name}>{this.state.product_detail ? this.state.product_detail.Product.alias : ''}</Text>

                    <Text style = {styles.text_product_price}>{'$' + (this.state.product_detail ? this.state.product_detail.Product.sell_price : '')}</Text>


                    <View style = {styles.view_xing}>


                      {xing}

                       <Text style = {[styles.text_product_price,{fontSize:12,marginLeft:8}]}>{avg_rating}</Text>

                    <Text></Text>
                 

                   </View>



                   <Text style = {styles.text_quantity}>Quantity</Text>


                   <View style = {styles.view_product_num}>


                     <TouchableOpacity  
                        onPress={this.clickNumJian.bind(this)}>

                       <Image
                          style={{width:26,height:26}}
                          source={require('../../../../images/jian_525.png')}
                          resizeMode = 'contain' />

                    </TouchableOpacity>  

                     

                      <Text style = {styles.text_num}>{this.state.product_num}</Text>


                     <TouchableOpacity  
                        onPress={this.clickNumAdd.bind(this)}>


                         <Image
                          style={{width:26,height:26}}
                          source={require('../../../../images/jia_525.png')}
                          resizeMode = 'contain' />    
                        

                    </TouchableOpacity>    

                     



                   </View>




                  </View>




              </View>



               <View style = {{width:'100%'}}>

                    <View style = {styles.view_table_head}>


                      <TouchableOpacity 
                        style = {styles.view_table_head_item}
                        activeOpacity = {0.8 }
                        onPress={this.clickTablePage.bind(this,0)}>

                        <View style = {styles.view_table_head_item}>

                          <Text style = {[styles.text_table,{color: this.state.table_page == 0 ? '#C44729' : '#000000',fontWeight : this.state.table_page == 0 ? 'bold' : 'normal' }]}>About</Text>

                        </View>

                     </TouchableOpacity>   


                      <TouchableOpacity 
                        style = {styles.view_table_head_item}
                        activeOpacity = {0.8 }
                        onPress={this.clickTablePage.bind(this,1)}>


                        <View style = {styles.view_table_head_item}>

                          <Text style = {[styles.text_table,{color: this.state.table_page == 1 ? '#C44729' : '#000000',fontWeight : this.state.table_page == 1 ? 'bold' : 'normal' }]}>Review</Text>

                        </View>


                      </TouchableOpacity>  

                    
                    </View>


                    <View style = {{width:'100%',height:2, flexDirection: 'row',}}>


                      <View style = {{flex:1, justifyContent: 'center',alignItems: 'center',}}>

                          <View style = {{width:97,height:2,backgroundColor:this.state.table_page ==  0 ? '#C44729' : '#FFFFFF'}}/>

                      </View>


                      <View style = {{flex:1, justifyContent: 'center',alignItems: 'center',}}>

                          <View style = {{width:97,height:2,backgroundColor:this.state.table_page ==  1 ? '#C44729' : '#FFFFFF'}}/>

                      </View>


                    </View>


                    <View style = {styles.view_line}/>

                  </View> 


                 {this.state.table_page == 0 ? 
                 
                   <ProductAboutTable 
                    tabLabel="About" 
                    product_detail = {this.state.product_detail} 
                    product_data = {this.state.product_data}/>

                    : 

                  <ProductReviewTable 
                    tabLabel="Review" 
                    product_review_detail = {this.state.product_review_detail} />  


                 } 

          </ScrollView>    



          <View style = {styles.xpop_cancel_confim}>

              <TouchableOpacity   
                 style = {styles.xpop_touch}   
                 activeOpacity = {0.8}
                 onPress={this.clickAddCart.bind(this)}>


                  <View style = {[styles.xpop_item,{backgroundColor:'#e0e0e0'}]}>

                    <Text style = {[styles.xpop_text,{color:'#333'}]}>Add to Cart</Text>

                 </View>


              </TouchableOpacity>   



              <TouchableOpacity
                 style = {styles.xpop_touch}    
                 activeOpacity = {0.8}
                 onPress={this.clickBuyNow.bind(this)}>

                  <View style = {[styles.xpop_item,{backgroundColor:'#C44729'}]}>

                    <Text style = {[styles.xpop_text,{color:'#fff'}]}>Buy Now</Text>

                </View>

              </TouchableOpacity>   

                       
           </View>       



        </SafeAreaView>


        <SafeAreaView style = {styles.afearea_foot} />



       </View>

      );


   }
}


const styles = StyleSheet.create({

  bg: {
    flex:1,
    backgroundColor:'#FFFFFF',
  },
  afearea:{
    flex:1,
    backgroundColor:'#145A7C'
  },
  afearea_foot:{
    flex:0,
    backgroundColor:'#FFFFFF'
  },
   header: {
    width: '100%',
    height: 50,
    backgroundColor: '#145A7C',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  rightView: {
    width: 50,
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },
  text_title :{
    color:'#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
  view_car_like:{
    height:'100%',
    flexDirection: 'row',
  },
  scrollview:{
    flex:1,
    backgroundColor:'#FFFFFF'
  },
  view_product_head:{
    width:'100%',
  },
  view_product_image:{
    width:'100%',
    height:357,
    backgroundColor:'#F2F2F2'
  },
  view_product_info:{
    padding:24,
    marginTop:-10,
    width:'100%',
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16
  },
  text_product_name:{
    fontSize:24,
    fontWeight:'bold',
    color: '#145A7C',
  },
  text_product_price:{
    marginTop:4,
    fontSize:18,
    color: '#4D333333',
  },
  view_xing:{
    marginTop:4,
    width:'100%',
    flexDirection: 'row',
  },
  text_quantity:{
    marginTop:30,
    color:'#333',
    fontSize: 14,
    fontWeight: 'bold',
  },
  view_product_num:{
    marginTop:8,
    width:'100%',
    flexDirection: 'row',
  },
  text_num:{
    width:30,
    marginTop:4,
    color:'#333',
    fontSize: 14,
    fontWeight: 'bold',
    textAlign:'center',
  },
  xpop_cancel_confim:{
    paddingTop:10,
    backgroundColor:'#FFFFFF',
    width:'100%',
    paddingLeft:24,
    paddingRight:24,
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingBottom:24,
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
  view_table_head:{
    width:'100%',
    height:50,
    backgroundColor:'#ffffff',
    flexDirection: 'row',
  },
  view_table_head_item:{
    flex:1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  view_line:{
    width:'100%',
    height:1,
    backgroundColor:'#E5E5E5',
  },
  text_table:{
    fontSize:14,
  }
});