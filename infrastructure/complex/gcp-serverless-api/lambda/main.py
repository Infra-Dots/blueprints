import functions_framework
from google.cloud import firestore

db = firestore.Client()

@functions_framework.http
def hello_http(request):
    """HTTP Cloud Function.
    Args:
        request (flask.Request): The request object.
    Returns:
        The response text, or any set of values that can be turned into a
        Response object using `make_response`.
    """
    
    # Simple Counter Logic
    doc_ref = db.collection(u'visitors').document(u'counter')
    
    @firestore.transactional
    def update_in_transaction(transaction, doc_ref):
        snapshot = doc_ref.get(transaction=transaction)
        new_count = 1
        if snapshot.exists:
            new_count = snapshot.get(u'count') + 1
            
        transaction.set(doc_ref, {u'count': new_count})
        return new_count

    transaction = db.transaction()
    count = update_in_transaction(transaction, doc_ref)
    
    return f'Hello from Cloud Functions! Visitor count: {count}'
