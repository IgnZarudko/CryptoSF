import { api, track, LightningElement } from 'lwc';
import getCryptoCurrencies from '@salesforce/apex/CryptocurrencyDatatableController.getCryptoCurrencies';

export default class CryptocurrencyDatatable extends LightningElement {

    @track cryptocurrencies = [];
    @track error;


    connectedCallback() {
        getCryptoCurrencies({pageNumber: 0})
        .then(result => {
            this.cryptocurrencies = result;
        })
        .catch(error => {
            console.log(error);
        })
    }
}