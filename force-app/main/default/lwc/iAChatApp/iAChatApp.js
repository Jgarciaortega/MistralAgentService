import { LightningElement, track } from 'lwc';
import handleInputText from '@salesforce/apex/IAChatController.handleInputText';

export default class IAChatApp extends LightningElement {
    @track messages = [];

    handleNewMessage(event) {
        const inputText = event.detail;
        this.messages = [...this.messages, { id: this.messages.length + 1, text: inputText, type: 'user' }];
        this.sendInputTextToApex(inputText);
    }

    sendInputTextToApex(inputText) {
        handleInputText({ inputText })
            .then(result => {
                console.log('Respuesta del servicio desde IAChatApp:', result);
                this.messages = [...this.messages, { id: this.messages.length + 1, text: result, type: 'service' }];
            })
            .catch(error => {
                console.error('Error al enviar texto a Apex:', error);
            });
    }
}