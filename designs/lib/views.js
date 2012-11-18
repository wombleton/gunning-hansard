exports.pages = {
    map: function(doc) {
        if (doc['type'] === 'page') {
            emit(doc.href, null);
        }
    }
};

exports.unscraped_pages = {
    map: function(doc) {
        if (doc['type'] === 'page' && doc.scraped !== true) {
            emit(doc.href, null);
        }
    }
};

exports.rated_questions = {
    map: function(doc) {
        if (doc['type'] === 'question' && doc.rated === true) {
            emit(doc._id, null);
        }
    }
}

exports.unrated_questions = {
    map: function(doc) {
        if (doc['type'] === 'question' && doc.rated !== true) {
            emit(doc._id, null);
        }
    }
}

exports.blocks = {
    map: function(doc) {
        var key;
        if (doc.type === 'block') {
            key = [].concat(doc.date);
            key.reverse();
            key.unshift(doc.subject);
            key.unshift(doc.speaker.toUpperCase());
            emit(key, null);
        }
    }
}
