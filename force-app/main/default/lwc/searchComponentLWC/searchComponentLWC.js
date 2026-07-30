import { LightningElement, track } from 'lwc';
import serachProds from '@salesforce/apex/SearchController.retriveProducts';

// datatable columns
const columns = [
{
    label: 'Name',
    fieldName: 'Name',
    type: 'url',
    typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}
}, {
    label: 'Product Code',
    fieldName: 'ProductCode',
    type: 'text',
}, 
];

export default class SearchComponentLWC extends LightningElement {
    @track searchData;
    @track columns = columns;
    @track strSearchProdName;
    
            handleProductName(event) {
                this.strSearchProdName = event.detail.value;
                serachProds({strProdName : this.strSearchProdName})
                .then(result => {
                this.searchData = result;
            })
        }
}