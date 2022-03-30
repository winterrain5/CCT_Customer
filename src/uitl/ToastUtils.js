    import Toast from 'react-native-root-toast';
    import {
      View,
      StyleSheet,
      ActivityIndicator,
      Dimensions,
      NativeModules
    } from 'react-native'
    let toast;
    /**
     * 冒一个时间比较短的Toast
     * @param content
     */
    export const toastShort = (content) => {
      NativeModules.NativeBridge.showMessage(content);
    };

    export const toastSuccess = (content) => {
      NativeModules.NativeBridge.showSuccessWith(content);
    };

    export const toastError = (content) => {
      NativeModules.NativeBridge.showErrorWith(content);
    };

    /**
     * 冒一个时间比较久的Toast
     * @param content
     */
    export const toastLong = (content) => {
      NativeModules.NativeBridge.showMessage(content);
    };