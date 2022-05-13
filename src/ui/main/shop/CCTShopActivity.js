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
  Dimensions,
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

import Swiper from 'react-native-swiper';

let nativeBridge = NativeModules.NativeBridge;

let {width, height} = Dimensions.get('window');


export default class CCTShopActivity extends Component {


  constructor(props) {
    super(props);
    this.state = {
       head_company_id:'97',
       userBean:undefined,
       shop_banner:undefined,
       page:0,
       isCctMap:1,
       shop_data:[],
       products_cart_count:0,
       filter_pamse:undefined,
       category:[],
       isRefreshing:false,
    }
  }


  UNSAFE_componentWillMount(){

  
    DeviceStorage.get('head_company_id').then((company_id) => {


      if (company_id) {
        this.setState({
            head_company_id: company_id,
          });
      }else {
        this.setState({
            head_company_id: '97',
          });

      }
    });


    this.cartCount();

    if (this.props) {

      if (this.props.isCctMap) {

        this.setState({
          isCctMap:this.props.isCctMap,
        });

      }else if (this.props.route && this.props.route.params) {

        this.setState({
          isCctMap:this.props.route.params.isCctMap,
        });

      }

    }
    
    DeviceStorage.get('UserBean').then((user_bean) => {

      this.setState({
          userBean: user_bean,
      });

      this.getNewFeaturedProducts(user_bean);

      this.getProductsByFilters(user_bean,undefined);

    });

    this.getTCategories();
     
  }


  _onRefresh(){

    this.setState({
      isRefreshing:true,
      filter_pamse:undefined,
    });

    this.getNewFeaturedProducts(this.state.userBean);

    this.getProductsByFilters(this.state.userBean,undefined);



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


      this.emit =  DeviceEventEmitter.addListener('shop_cart_up',(params)=>{
            //接收到详情页发送的通知，刷新首页的数据，改变按钮颜色和文字，刷新UI
           temporary.cartCount();
       });


  }

  componentWillUnmount(){

    this.emit.remove();
  
  }


  getTCategories(){

     var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getTCategories id="o0" c:root="1" xmlns:n0="http://terra.systems/"><showProCount i:type="d:string">false</showProCount><productType i:type="d:string">TCM_INVENTORY_PRODUCT_NAME</productType><companyId i:type="d:string">97</companyId></n0:getTCategories></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('category','getTCategoriesResponse',data, function(json) {

        if (json && json.success == 1 && json.data && json.data.length > 0) {
           temporary.setState({
              category:json.data, 
           });
        }

    });      


  }


  getNewFeaturedProducts(userBean){


    if (!userBean) {
      return
    }
    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getNewFeaturedProducts id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">'+ this.state.head_company_id+'</companyId>'+
    '<isFeatured i:type="d:string">1</isFeatured>'+
    '<isCctMap i:type="d:string">' + this.state.isCctMap + '</isCctMap>'+
    '<isOnline i:type="d:string">1</isOnline>'+
    '<isNew i:type="d:string">false</isNew>'+
    '<limit i:type="d:string">4</limit>'+
    '<clientId i:type="d:string">'+ userBean.id +'</clientId>'+
    '</n0:getNewFeaturedProducts></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('product','getNewFeaturedProductsResponse',data, function(json) {

        if (json && json.success == 1) {
           temporary.setState({
              shop_banner:json.data, 
           });
        }

        temporary.setState({
          isRefreshing:false,
        })

    });      


  }


  getProductsByFilters(userBean,filter_pamse){

    if (!userBean) {
      return;
    }

    var price_high = '';
    var price_low = '0';
    var categoryId = '';
    var orderBy = '';


    if (filter_pamse) {

      if (filter_pamse.range) {

        var price = filter_pamse.range.split('-');


        if (price) {
          price_low = price[0];
          price_high = price[1];
        }
      }

      if (filter_pamse.filter == 1) {

          orderBy = 'DESC';

      }else if (filter_pamse.filter == 0) {

          orderBy = 'ASC';
      }

      if (filter_pamse.category) {

        for (var i = 0; i < filter_pamse.category.length; i++) {
           var category_id = filter_pamse.category[i];


           if (categoryId == '') {
            categoryId = category_id;

           }else {

            categoryId += (',' + category_id);

           }

        }

      }

    }

    var data = '<v:Envelope xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns:d="http://www.w3.org/2001/XMLSchema" xmlns:c="http://schemas.xmlsoap.org/soap/encoding/" xmlns:v="http://schemas.xmlsoap.org/soap/envelope/"><v:Header /><v:Body><n0:getProductsByFilters id="o0" c:root="1" xmlns:n0="http://terra.systems/">'+
    '<companyId i:type="d:string">' + this.state.head_company_id+'</companyId>'+
    '<length i:type="d:string">500</length>'+
    '<searchValue i:type="d:string"></searchValue>'+
    '<isOnline i:type="d:string">1</isOnline>'+
    '<data i:type="n1:Map" xmlns:n1="http://xml.apache.org/xml-soap">'+
    '<item><key i:type="d:string">price_high</key><value i:type="d:string">'+ price_high + '</value></item>'+
    '<item><key i:type="d:string">price_low</key><value i:type="d:string">'+ price_low +'</value></item>'+
    '<item><key i:type="d:string">categoryId</key><value i:type="d:string">'+ categoryId + '</value></item>'+
    '<item><key i:type="d:string">isCctMap</key><value i:type="d:string">'+ this.state.isCctMap+'</value></item>'+
    '<item><key i:type="d:string">orderBy</key><value i:type="d:string">'+ orderBy +'</value></item>'+
    '</data>'+
    '<start i:type="d:string">1</start>'+
    '<clientId i:type="d:string">'+ userBean.id+'</clientId>'+
    '</n0:getProductsByFilters></v:Body></v:Envelope>';

    var temporary = this;
    WebserviceUtil.getQueryDataResponse('product','getProductsByFiltersResponse',data, function(json) {

        if (json && json.success == 1 && json.data) {
           temporary.setState({
              shop_data:json.data.data, 
           });
        }else {
          temporary.setState({
              shop_data:[], 
           });
        }

    });      


  }


  back(){

    if (this.props.navigation) {
      this.props.navigation.goBack();
    }else {
      NativeModules.NativeBridge.goBack();
    }

  }

  clickLike(){

    NativeModules.NativeBridge.log(JSON.stringify(this.props));
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


  shopBanner(){


    if  ( this.state.shop_banner) {

       var pages = [];


       for (var i = 0; i < this.state.shop_banner.length; i++) {
        

          var picture = this.state.shop_banner[i].picture;

          var image_url = picture.slice(1,picture.length);



          pages.push(

             <TouchableOpacity
                key = {i + ''}
                style = {styles.img_banner}  
                onPress={this.clickProduct.bind(this,this.state.shop_banner[i])}>

                  <Image 
                    key = {i + ''}
                    style={styles.img_banner}
                    source={{uri: WebserviceUtil.getImageHostUrl() + image_url}}
                    resizeMode="cover" />
                

             </TouchableOpacity>   


           );

       }





      return (

          <Swiper
            loop={true}  
            height={257}
            index = {this.state.page}
            showsPagination={true} 
            paginationStyle={{bottom: 24}}
            autoplay={true} 
            horizontal={true}
            dot={<View style = {[styles.indicator_item,{backgroundColor:'#BDBDBD'}]}></View>}
            activeDot={<View style = {[styles.indicator_item,{backgroundColor:'#145A7C'}]}></View>}
            >

            {pages}

          </Swiper>   

        );
    }else {

      return (<View />);

    }


  }


   _renderItem = (item) => {

      var xing1 = [];
      var avg_rating_1 = parseInt(item.item.avg_rating);
     
      var picture1 = item.item.picture;
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


      return (

             <TouchableOpacity  
                style = {styles.view_product_item}
                onPress={this.clickShopItem.bind(this,item)}>


                <View style = {[styles.view_product_item,{marginRight:8,marginBottom:8}]}>

                  <View style = {{flex:1,height:120,flexDirection:'row-reverse'}}>

                      <View style = {styles.view_image_card}>

                           <Image 
                            style={{flex:1,borderRadius:16}}
                            source={{uri: WebserviceUtil.getImageHostUrl() + image_url1}}
                            resizeMode="cover" />

                      </View>

                     

                        <TouchableOpacity
                          style = {styles.view_item_like}
                          onPress={this.clickLikeProduct.bind(this,item)}>


                          <View style = {styles.view_item_like}>


                            <Image
                              style={{width:15,height:15}}
                              source={item.item.isLike ? require('../../../../images/xing_hong_1223.png') : require('../../../../images/bai_xing.png')}
                              resizeMode = 'contain' />

                    
                          </View>

                       </TouchableOpacity>   

                 </View>

                <Text style = {styles.text_product_name} numberOfLines={1}>{item.item.alias}</Text>

                <Text style = {styles.text_product_price} numberOfLines={1}>{'$' + item.item.sell_price}</Text>

                <View style = {styles.view_xing}>

                  {xing1}

                </View>

             </View> 



             </TouchableOpacity>         

             
        );
    
   }


   clickShopItem(item){

    if (this.props.isNative) {
      NativeModules.NativeBridge.openNativeVc("RNBridgeViewController",{pageName:"ShopProductDetailActivity",property:{'product_id':item.item.id}});
      return;
    }

    const { navigation } = this.props;
   
    if (navigation) {
      navigation.navigate('ShopProductDetailActivity',{
        'product_id':item.item.id
      });
    }

   }

   clickProduct(item){

      if (this.props.isNative) {
        NativeModules.NativeBridge.openNativeVc("RNBridgeViewController",{pageName:"ShopProductDetailActivity",property:{'product_id':item.item.id}});
        return;
      }


      const { navigation } = this.props;

      if (navigation) {
        navigation.navigate('ShopProductDetailActivity',{
          'product_id':item.id
        });
      }


   }


   clickLikeProduct(item){

    if(item.item.isLike){

      this.deleteLikeProduct(item.item.id);
    }else {

      this.saveLikeProduct(item.item.id);
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
          temporary.getProductsByFilters(temporary.state.userBean);
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
            temporary.getProductsByFilters(temporary.state.userBean);
        }

    });      
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


  clickUpdate(){



  }



  clickFilter(){


    var temporary = this;

    nativeBridge.showFilterView(false,(error, result) => {
        
        if (result) {

          var filter_pamse = JSON.parse(result,'utf-8');

          temporary.setState({
            filter_pamse:filter_pamse,
          });

          temporary.getProductsByFilters(temporary.state.userBean,filter_pamse);

        }
    });

  }


  _selectedFilter(){


    if (this.state.filter_pamse) {

       var pages = [];

      if (this.state.filter_pamse.filter == 0) {

        pages.push(

           <View style = {styles.view_fileter_item}>

              <Text style = {styles.text_filter_item}>$ High to Low</Text>

           </View>

        );

      }else if (this.state.filter_pamse.filter == 1) {

           pages.push(

           <View style = {styles.view_fileter_item}>

              <Text style = {styles.text_filter_item} >$ Low to High</Text>

           </View>

        );
      }


      if (this.state.category && this.state.filter_pamse.category && this.state.filter_pamse.category.length > 0) {


        for (var i = 0; i < this.state.filter_pamse.category.length; i++) {
            
            var selseted_category_id = this.state.filter_pamse.category[i];

            for (var j = 0; j < this.state.category.length; j++) {
              
              if (selseted_category_id ==  this.state.category[j].id ) {

                  pages.push(

                     <View style = {styles.view_fileter_item}>

                        <Text style = {styles.text_filter_item} >{this.state.category[j].name}</Text>

                     </View>

                  );

                  break;

              }


            }

        }

      }


      if (this.state.filter_pamse.range) {

          pages.push(

             <View style = {styles.view_fileter_item}>

                <Text style = {styles.text_filter_item} > $ {this.state.filter_pamse.range}</Text>

             </View>

          );


      }




    


      return (

        <ScrollView 
            style = {{marginLeft:5}}
            showsHorizontalScrollIndicator = {false}
            horizontal={true}
            contentOffset={{x: 0, y: 0}}>
            {pages}
        </ScrollView>  

      );






    }else {


      return (<View />);


    }



  }





   render() {

    return(

      <View style = {styles.bg}>

         <StatusBar barStyle="light-content" backgroundColor='#FFFFFF' translucent={false} />


          <SafeAreaView style = {[styles.afearea,{backgroundColor:this.state.isCctMap == 1 ? '#145A7C' : '#EE8F7B'}]} >


            <View style = {[styles.header,{backgroundColor:this.state.isCctMap == 1 ? '#145A7C' : '#EE8F7B'}]}>


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
              style = {styles.scrollview}
              stickyHeaderIndices = {[1]}
              showsVerticalScrollIndicator = {false}
              contentOffset={{x: 0, y: 0}}
               refreshControl={
                <RefreshControl
                    refreshing={this.state.isRefreshing}
                    onRefresh={this._onRefresh.bind(this, 0)}
                />
               }
              onScroll={this.changeScroll}>



              <View style = {{width:'100%'}}>


                <Text style = {[styles.text_cct_title,{color:this.state.isCctMap == 1 ? '#145A7C' : '#EE8F7B'}]}>{this.state.isCctMap == 0 ? 'Chien Chi Tow' : 'Madam Partum'}</Text>


                <View style = {styles.view_banner}>


                     {this.shopBanner()}


                </View>

              </View>


              <View style = {{width:'100%',backgroundColor:'#FFFFFF'}}>


                  <View style = {styles.view_search}>


                      <TextInput
                        style={styles.textInput}
                        placeholder="Search"/>


                  </View>


                  <View style = {styles.view_filter}>


                    <TouchableOpacity  
                      onPress={this.clickFilter.bind(this)}>

                      <View style = {{flexDirection: 'row'}}>

                           <Image
                              style={{width:20,height:20}}
                              source={require('../../../../images/hong_menu_more.png')}
                              resizeMode = 'contain' />

                          <Text style = {styles.text_filter}>Filter</Text>    



                      </View>

                    </TouchableOpacity>  


                    {this._selectedFilter()}
             
                  </View>

              </View>


              <FlatList
                style = {styles.flatList}
                ref = {(flatList) => this._flatList = flatList}
                renderItem = {this._renderItem}
                onEndReachedThreshold={0.5}
                numColumns ={2}
                keyExtractor={(item, index) => index.toString()}
                data={this.state.shop_data}/>



            </ScrollView>  



          </SafeAreaView>



          <CoverLayer ref={ref => this.coverLayer = ref}/> 


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
  text_cct_title:{
    margin:24,
    width:'100%',
    color:'#145A7C',
    fontSize: 24,
    fontWeight: 'bold',
  },
  view_banner:{
    width:'100%',
    height:257,
    backgroundColor:'#F2F2F2'
  },
  img_banner:{
    width:'100%',
    height:257,
  },
  indicator_item:{
    width:24,
    height:4,
    backgroundColor:'#000000',
    borderRadius: 50,
    marginLeft:4,
  },
  view_search:{
    paddingTop:8,
    paddingLeft:16,
    paddingRight:16,
    paddingBottom:8,
    borderRadius: 50,
    margin:24,
    height:40,
    borderWidth:0.5,
    borderColor:'#CCC'
  },
  view_fileter_item:{
    marginLeft:8,
    paddingTop:5,
    paddingLeft:16,
    paddingRight:16,
    paddingBottom:5,
    borderRadius: 50,
    borderWidth:0.5,
    borderColor:'#CCC'
  },



  textInput:{
    flex:1,
  },
  view_filter:{
    paddingLeft:24,
    width:'100%',
    flexDirection: 'row'
  },
  text_filter:{
    marginTop:2,
    marginLeft:10,
    color:'#C44729',
    fontSize: 14,
    fontWeight: 'bold',
  },
  view_product:{
    marginTop:16,
    width:'100%',
    flexDirection: 'row',
  },
  view_product_item:{
    width:(width - 48)/2,
    flex:1,
    height:190
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
  flatList:{
    marginTop:24,
    marginLeft:24,
    marginRight:16,
    marginBottom:24,
    flex:1,
  },
  view_popup_bg :{
    width:'100%',
    padding:24,
    backgroundColor:'#FFFFFF',
    borderTopLeftRadius:16,
    borderTopRightRadius:16,
    justifyContent: 'center',
    alignItems: 'center'
  },
  text_popup_title:{
    width:'100%',
    fontSize:24,
    color:'#145A7C',
    fontWeight:'bold',
    marginBottom:20,
  },
  view_high_low:{
    marginTop:12,
    width:'100%',
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  view_pop_item:{
    marginTop:12,
    marginRight:12,
    paddingTop:8,
    paddingLeft:12,
    paddingRight:16,
    paddingBottom:8,
    borderRadius: 50,
    backgroundColor:'#FFFFFF',
    borderWidth:0.5,
    borderColor:'#CCC',
    justifyContent: 'center',
    alignItems: 'center'
  },
  text_category_title:{
    marginTop:32,
    width:'100%',
    fontSize:18,
    color:'#145A7C',
    fontWeight:'bold',
  },
  xpop_item:{
    borderRadius: 50,
    height:44,
    justifyContent: 'center',
    alignItems: 'center',
  },
  text_filter_item:{
    color:'#BDBDBD',
      fontSize:14,
  }
});