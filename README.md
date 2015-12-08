# ActiveRecordLite

Features:
Obj.all Returns all the objects of the same class.

Obj.where(params) Search for an object satisfying the params.
For example:  Cat.where("name => ? AND color => ?", "sennacy", "black")

Obj.find(obj_id) Search for an Object by its id.

Also implements relational queries such. You can specify relationships
between objects by using has_many or belongs_to. That would let you do
things like sennacy.owner.name, or owner.cats, For if Cat belongs_to Owner,
and Owner has_many cats, respectively.

Todos:
- [ ] Complete has_many through relation.
