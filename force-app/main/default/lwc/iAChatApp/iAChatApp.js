import { LightningElement, track } from 'lwc';
import handleInputText from '@salesforce/apex/IAChatController.handleInputText';

export default class IAChatApp extends LightningElement {
    @track messages = [];

    handleNewMessage(event) {
        const inputText = event.detail;
        const timestamp = new Date().toLocaleTimeString();
        const userMessage = { id: this.messages.length + 1, text: inputText, type: 'user', timestamp: timestamp };
        console.log('User message:', userMessage);
        this.messages = [...this.messages, userMessage];
        this.sendInputTextToApex(inputText);
    }

    handleEndChat() {
        this.messages = [];
    }

    sendInputTextToApex(inputText) {
        handleInputText({ inputText })
            .then(result => {
                const timestamp = new Date().toLocaleTimeString();
                const serviceMessage = { id: this.messages.length + 1, text: result, type: 'service', timestamp: timestamp };
                console.log('Service message:', serviceMessage);
                this.messages = [...this.messages, serviceMessage];
            })
            .catch(error => {
                console.error('Error al enviar texto a Apex:', error);
            });
    }
}