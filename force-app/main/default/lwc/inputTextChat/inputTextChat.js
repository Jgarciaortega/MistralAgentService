import { LightningElement } from 'lwc';

export default class InputTextChat extends LightningElement {

    handleInputChange(event) {
        let inputText;

        if (event.key === 'Enter') {
            inputText = event.target.value;

            if(inputText != null && inputText != ''){
                console.log('Input text:', inputText);
                this.clearInput(event.target);
                this.dispatchEvent(new CustomEvent('newmessage', { detail: inputText }));
            }
        }
    }

    handleClickEndChat(event) {
        if (event.target.label === 'End Chat') {
            this.dispatchEvent(new CustomEvent('endchat'));
        }
    }

    clearInput(element){
        element.value = '';
    }
}