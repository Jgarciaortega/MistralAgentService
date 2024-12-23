import { LightningElement, api } from 'lwc';

export default class DashboardChat extends LightningElement {
    @api messages = [];

    get computedMessages() {
        return this.messages.map(message => {
            return {
                ...message,
                cssClass: message.type === 'user' ? 'chat-message-user chat-message' : 'chat-message-service chat-message'
            };
        });
    }
}