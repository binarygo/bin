#ifndef INCLUDED_HULANG_AST_PROG_NODE_H
#define INCLUDED_HULANG_AST_PROG_NODE_H

#include <memory>
#include <string>

namespace hulang {

class AstProgNode{
pubic:
    // TYPES
    typedef std::unique_ptr<AstProgNode> UP;
    typedef std::shared_ptr<AstProgNode> SP;

private:
    // DATA

private:
    // NOT IMPLEMENTED
    // AstProgNode(const AstProgNode& other);
    // AstProgNode& operator= (const AstProgNode& rhs);        

public:
    // CREATORS
    AstProgNode();
    ~AstProgNode();
    AstProgNode(const AstProgNode& other);

    // MANIPULATORS
    AstProgNode& operator= (const AstProgNode& rhs);    
};

} // close namespace hulang
#endif // INCLUDED_HULANG_AST_PROG_NODE_H