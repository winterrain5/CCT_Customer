import React, {Component} from 'react'
import {TextInput, Text, Platform, UIManager, LayoutAnimation, StyleSheet, View} from "react-native";

import PropTypes from 'prop-types';

export default class IparInput extends Component {



    static propTypes = {
        isPassword: PropTypes.bool,
        placeholderText: PropTypes.string.isRequired,
        valueText :PropTypes.string,
        onChangeText:PropTypes.func,
        onBlur:PropTypes.func,
        onFocus:PropTypes.func,
    }


    constructor(props) {
        super(props);
        this.inputValue = this.props.valueText ? this.props.valueText : '';
        this.state = {
            isFocused:  this.props.valueText ? true : false,
            marginBottom: this.props.valueText ? 30 : 0,
        }
    }

    // UNSAFE_componentWillReceiveProps(){


    //     console.error(this.props.valueText.length);

    //     this.inputValue = this.props.valueText ? this.props.valueText : '';
    //     this.setState ({
    //         isFocused:  this.props.valueText ? true : false,
    //         marginBottom: this.props.valueText ? 30 : 0,
    //     });

    // }

    static  getDerivedStateFromProps(props, state) {

        // if(props.valueText !== this.inputValue){

        //     this.inputValue = props.valueText ? props.valueText : '';

        //     return {
        //          isFocused:  props.valueText ? true : false,
        //          marginBottom: props.valueText ? 30 : 0,
        //     }
        // }

         this.inputValue = props.valueText ? props.valueText : '';

            return {
                 isFocused:  props.valueText ? true : false,
                 marginBottom: props.valueText ? 30 : 0,
            }

        return null
    }




    startAnim(isFocused) {
        if (Platform.OS === 'android') {
            UIManager.setLayoutAnimationEnabledExperimental(true);
        }
        /**
         * 动画效果
         */
        LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut);


        let _marginValue = isFocused || this.inputValue.trim() ? 30 : 10;

        this.setState({
            marginBottom: _marginValue,
            isFocused: isFocused,
        })
    }

    render() {

        let state = this.state;



        return <View style={[styles.inputBox, !state.isFocused ]}>

            <View style={[styles.placeholderBox, {bottom: state.marginBottom}]}>
                <Text
                    style={[{
                        fontSize: 16,
                        paddingBottom: state.marginBottom !== 0 ? 5: 10,
                        color: '#828282',
                        textAlign: 'left',
                    }]}>
                    {this.props.placeholderText}
                </Text>
            </View>
            <TextInput
                multiline = {false}
                placeholder=''
                onChangeText={(text) => {
                    this.inputValue = text;
                    this.props.onChangeText && this.props.onChangeText(text);
                }}
                onBlur={() =>{
                    this.startAnim(false);
                    this.props.onBlur && this.props.onBlur();
                    
                }}
                onFocus={() => {
                    this.startAnim(true);
                    this.props.onFocus && this.props.onFocus();
                }}
                value = {this.props.valueText}
                secureTextEntry={this.props.isPassword === true}
                underlineColorAndroid='transparent'
                style={styles.input}
            />

            <View style={{
                backgroundColor: "#E0E0E0",
                width: '100%',
                height: 1
            }}/>
        </View>
    }
}
const styles = StyleSheet.create({
    input: {
        height: 40,
        width: '100%',
        textAlign: 'left',
    },
    inputBox: {
        height: 60,
        justifyContent: 'flex-end',
    },
    placeholderBox: {
        justifyContent: 'flex-end',
        position: 'absolute',
        left: 0,
        right: 0,
    }
});